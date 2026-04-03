public with sharing class OrderTotalUpdater {
    public static void updateOrderTotal(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return;
        }

        Map<Id, Decimal> orderTotals = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Order__c orderId, SUM(Total_Price__c) totalAmount
            FROM AgriEdge_OrderItem__c
            WHERE Order__c IN :orderIds
            GROUP BY Order__c
        ]) {
            orderTotals.put((Id) ar.get('orderId'), (Decimal) ar.get('totalAmount'));
        }

        List<AgriEdge_Order__c> ordersToUpdate = new List<AgriEdge_Order__c>();
        for (AgriEdge_Order__c orderRecord : [
            SELECT Id, Total_Amount__c, Payment_Status__c
            FROM AgriEdge_Order__c
            WHERE Id IN :orderIds
        ]) {
            Decimal totalAmount = orderTotals.containsKey(orderRecord.Id) ? orderTotals.get(orderRecord.Id) : 0;
            orderRecord.Total_Amount__c = totalAmount;
            orderRecord.Payment_Status__c = totalAmount > 0 ? 'Pending' : 'Paid';
            ordersToUpdate.add(orderRecord);
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
}
