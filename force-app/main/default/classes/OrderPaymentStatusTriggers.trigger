trigger OrderPaymentStatusTriggers on AgriEdge_Order__c (after update) {
    Set<Id> updatedOrderIds = new Set<Id>();

    for (AgriEdge_Order__c orderRecord : Trigger.new) {
        AgriEdge_Order__c oldOrder = Trigger.oldMap.get(orderRecord.Id);
        if (oldOrder.Payment_Status__c != 'Paid'
            && orderRecord.Payment_Status__c == 'Paid'
            && orderRecord.Customer__c != null) {
            updatedOrderIds.add(orderRecord.Id);
        }
    }

    if (!updatedOrderIds.isEmpty()) {
        OrderEmailSender.sendOrderEmail(updatedOrderIds);
    }
}
