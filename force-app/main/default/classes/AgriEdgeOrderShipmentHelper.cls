public with sharing class AgriEdgeOrderShipmentHelper {
    public static void processOrderStatusChange(List<AgriEdge_Order__c> updatedOrders) {
        if (updatedOrders == null || updatedOrders.isEmpty()) {
            return;
        }

        List<AgriEdge_Shipment__c> shipmentsToInsert = new List<AgriEdge_Shipment__c>();
        List<AgriEdge_Shipment__c> shipmentsToUpdate = new List<AgriEdge_Shipment__c>();
        List<AgriEdge_Order__c> ordersToUpdate = new List<AgriEdge_Order__c>();
        List<AgriEdge_OrderItem__c> orderItemsToDelete = new List<AgriEdge_OrderItem__c>();
        List<AgriEdge_Shipment__c> shipmentsToDelete = new List<AgriEdge_Shipment__c>();

        Set<Id> orderIds = new Set<Id>();
        for (AgriEdge_Order__c orderRecord : updatedOrders) {
            orderIds.add(orderRecord.Id);
        }

        Map<Id, AgriEdge_Shipment__c> existingShipments = new Map<Id, AgriEdge_Shipment__c>();
        for (AgriEdge_Shipment__c shipmentRecord : [
            SELECT Id, Order__c, Status__c, Tracking_Number__c
            FROM AgriEdge_Shipment__c
            WHERE Order__c IN :orderIds
        ]) {
            existingShipments.put(shipmentRecord.Order__c, shipmentRecord);
        }

        Map<Id, List<AgriEdge_OrderItem__c>> existingOrderItems = new Map<Id, List<AgriEdge_OrderItem__c>>();
        for (AgriEdge_OrderItem__c orderItem : [
            SELECT Id, Order__c
            FROM AgriEdge_OrderItem__c
            WHERE Order__c IN :orderIds
        ]) {
            if (!existingOrderItems.containsKey(orderItem.Order__c)) {
                existingOrderItems.put(orderItem.Order__c, new List<AgriEdge_OrderItem__c>());
            }
            existingOrderItems.get(orderItem.Order__c).add(orderItem);
        }

        for (AgriEdge_Order__c orderRecord : updatedOrders) {
            if (orderRecord.Payment_Status__c == 'Paid' && orderRecord.Order_Status__c != 'Delivered') {
                ordersToUpdate.add(new AgriEdge_Order__c(
                    Id = orderRecord.Id,
                    Order_Status__c = 'Delivered'
                ));
            } else if (orderRecord.Payment_Status__c == 'Pending' && orderRecord.Order_Status__c != 'Processing') {
                ordersToUpdate.add(new AgriEdge_Order__c(
                    Id = orderRecord.Id,
                    Order_Status__c = 'Processing'
                ));
            } else if (orderRecord.Payment_Status__c == 'Failed') {
                ordersToUpdate.add(new AgriEdge_Order__c(
                    Id = orderRecord.Id,
                    Order_Status__c = 'Canceled'
                ));

                if (existingOrderItems.containsKey(orderRecord.Id)) {
                    orderItemsToDelete.addAll(existingOrderItems.get(orderRecord.Id));
                }
                if (existingShipments.containsKey(orderRecord.Id)) {
                    shipmentsToDelete.add(existingShipments.get(orderRecord.Id));
                }
            }

            if (orderRecord.Order_Status__c == 'Processing' && !existingShipments.containsKey(orderRecord.Id)) {
                shipmentsToInsert.add(new AgriEdge_Shipment__c(
                    Name = 'Shipment ' + String.valueOf(orderRecord.Id).right(5),
                    Order__c = orderRecord.Id,
                    Carrier__c = 'Local Courier',
                    Tracking_Number__c = 'TEST-' + String.valueOf(orderRecord.Id).right(8),
                    Status__c = 'Pending'
                ));
            } else if ((orderRecord.Order_Status__c == 'Shipped' || orderRecord.Order_Status__c == 'Delivered')
                && existingShipments.containsKey(orderRecord.Id)) {
                AgriEdge_Shipment__c shipmentToUpdate = existingShipments.get(orderRecord.Id);
                shipmentToUpdate.Status__c = orderRecord.Order_Status__c == 'Shipped' ? 'In Transit' : 'Delivered';
                if (shipmentToUpdate.Tracking_Number__c == null) {
                    shipmentToUpdate.Tracking_Number__c = 'TEST-' + String.valueOf(orderRecord.Id).right(8);
                }
                shipmentsToUpdate.add(shipmentToUpdate);
            }
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
        if (!shipmentsToInsert.isEmpty()) {
            insert shipmentsToInsert;
        }
        if (!shipmentsToUpdate.isEmpty()) {
            update shipmentsToUpdate;
        }
        if (!orderItemsToDelete.isEmpty()) {
            delete orderItemsToDelete;
        }
        if (!shipmentsToDelete.isEmpty()) {
            delete shipmentsToDelete;
        }
    }
}
