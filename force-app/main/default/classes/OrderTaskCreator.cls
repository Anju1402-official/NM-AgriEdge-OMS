public with sharing class OrderTaskCreator {
    public class Request {
        @InvocableVariable(required=true label='Order Id')
        public Id orderId;
    }

    @InvocableMethod(label='Create Tasks For New Order')
    public static void createTaskForNewOrder(List<Request> requests) {
        List<Id> orderIds = new List<Id>();
        if (requests != null) {
            for (Request requestItem : requests) {
                if (requestItem != null && requestItem.orderId != null) {
                    orderIds.add(requestItem.orderId);
                }
            }
        }
        createTasks(orderIds);
    }

    public static void createTasks(List<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return;
        }

        List<User> platformUsers = [
            SELECT Id
            FROM User
            WHERE Profile.Name = 'Platform 1'
            AND IsActive = true
            LIMIT 10
        ];

        if (platformUsers.isEmpty()) {
            return;
        }

        List<Task> tasks = new List<Task>();
        for (Id orderId : orderIds) {
            for (User userRecord : platformUsers) {
                tasks.add(new Task(
                    Subject = 'New Order Created',
                    Description = 'A new order has been created. Please create an Order Item record.',
                    WhatId = orderId,
                    OwnerId = userRecord.Id,
                    Status = 'Not Started',
                    Priority = 'High'
                ));
            }
        }

        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }
}
