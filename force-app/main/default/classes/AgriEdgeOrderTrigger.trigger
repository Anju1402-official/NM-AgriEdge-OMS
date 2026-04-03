trigger AgriEdgeOrderTrigger on AgriEdge_Order__c (after insert, after update) {
    if (AgriEdgeOrderTriggerHelper.isTriggerExecuted) {
        return;
    }
    AgriEdgeOrderTriggerHelper.isTriggerExecuted = true;

    try {
        List<AgriEdge_Order__c> relevantOrders = new List<AgriEdge_Order__c>();
        List<AgriEdge_Order__c> ordersToUpdate = new List<AgriEdge_Order__c>();
        List<Id> failedOrderIds = new List<Id>();

        for (AgriEdge_Order__c orderRecord : Trigger.new) {
            AgriEdge_Order__c oldOrder = Trigger.isUpdate ? Trigger.oldMap.get(orderRecord.Id) : null;
            Boolean paymentStatusChanged = oldOrder == null || orderRecord.Payment_Status__c != oldOrder.Payment_Status__c;
            Boolean orderStatusChanged = oldOrder == null || orderRecord.Order_Status__c != oldOrder.Order_Status__c;

            if (Trigger.isInsert || paymentStatusChanged || orderStatusChanged) {
                relevantOrders.add(orderRecord);
            }

            if (orderRecord.Payment_Status__c == 'Pending' && orderRecord.Order_Status__c != 'Processing') {
                ordersToUpdate.add(new AgriEdge_Order__c(
                    Id = orderRecord.Id,
                    Order_Status__c = 'Processing'
                ));
            }

            if (orderRecord.Payment_Status__c == 'Failed') {
                ordersToUpdate.add(new AgriEdge_Order__c(
                    Id = orderRecord.Id,
                    Order_Status__c = 'Canceled'
                ));
                failedOrderIds.add(orderRecord.Id);
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }

        if (!failedOrderIds.isEmpty()) {
            List<AgriEdge_OrderItem__c> orderItemsToDelete = [
                SELECT Id
                FROM AgriEdge_OrderItem__c
                WHERE Order__c IN :failedOrderIds
            ];
            List<AgriEdge_Shipment__c> shipmentsToDelete = [
                SELECT Id
                FROM AgriEdge_Shipment__c
                WHERE Order__c IN :failedOrderIds
            ];

            if (!orderItemsToDelete.isEmpty()) {
                delete orderItemsToDelete;
            }
            if (!shipmentsToDelete.isEmpty()) {
                delete shipmentsToDelete;
            }
        }

        if (!relevantOrders.isEmpty()) {
            AgriEdgeOrderShipmentHelper.processOrderStatusChange(relevantOrders);
        }
    } finally {
        AgriEdgeOrderTriggerHelper.isTriggerExecuted = false;
    }
}
