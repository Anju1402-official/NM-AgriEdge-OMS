trigger OrderItemTrigger on AgriEdge_OrderItem__c (after insert, after update) {
    Set<Id> orderIds = new Set<Id>();

    for (AgriEdge_OrderItem__c orderItem : Trigger.new) {
        if (orderItem.Order__c != null) {
            orderIds.add(orderItem.Order__c);
        }
    }

    if (!orderIds.isEmpty()) {
        OrderStatusUpdater.updateOrderStatus(orderIds);
        OrderTotalUpdater.updateOrderTotal(orderIds);
    }
}
