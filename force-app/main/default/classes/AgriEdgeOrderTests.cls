@IsTest
public class AgriEdgeOrderTests {
    private static Account createAccount() {
        Account testAccount = new Account(Name = 'Test Customer ' + System.now().getTime());
        insert testAccount;
        return testAccount;
    }

    private static Product2 createProduct() {
        Product2 product = new Product2(
            Name = 'Test Product ' + System.now().getTime(),
            ProductCode = 'TP-' + String.valueOf(Crypto.getRandomInteger()).replace('-', '1').left(6),
            IsActive = true
        );
        insert product;
        return product;
    }

    private static AgriEdge_Order__c createOrder(Id accountId, String paymentStatus, String orderStatus) {
        AgriEdge_Order__c orderRecord = new AgriEdge_Order__c(
            Customer__c = accountId,
            Order_Status__c = orderStatus,
            Order_Date__c = System.now(),
            Payment_Status__c = paymentStatus,
            Shipping_Address__c = '123 Test Street'
        );
        insert orderRecord;
        return orderRecord;
    }

    @IsTest
    static void testOrderTaskCreatorGracefullyHandlesMissingPlatformProfile() {
        Account accountRecord = createAccount();
        AgriEdge_Order__c orderRecord = createOrder(accountRecord.Id, 'Pending', 'New');
        Integer taskCountBefore = [SELECT count() FROM Task WHERE WhatId = :orderRecord.Id];
        Integer platformUserCount = [SELECT count() FROM User WHERE Profile.Name = 'Platform 1' AND IsActive = true];

        Test.startTest();
        OrderTaskCreator.createTasks(new List<Id>{ orderRecord.Id });
        Test.stopTest();

        Integer taskCountAfter = [SELECT count() FROM Task WHERE WhatId = :orderRecord.Id];
        System.assertEquals(taskCountBefore + platformUserCount, taskCountAfter);
    }

    @IsTest
    static void testOrderStatusUpdater() {
        Account accountRecord = createAccount();
        AgriEdge_Order__c order1 = createOrder(accountRecord.Id, 'Pending', 'New');
        AgriEdge_Order__c order2 = createOrder(accountRecord.Id, 'Pending', 'Processing');

        Test.startTest();
        OrderStatusUpdater.updateOrderStatus(new Set<Id>{ order1.Id, order2.Id });
        Test.stopTest();

        Map<Id, AgriEdge_Order__c> refreshedOrders = new Map<Id, AgriEdge_Order__c>([
            SELECT Id, Order_Status__c
            FROM AgriEdge_Order__c
            WHERE Id IN :new Set<Id>{ order1.Id, order2.Id }
        ]);
        System.assertEquals('Processing', refreshedOrders.get(order1.Id).Order_Status__c);
        System.assertEquals('Processing', refreshedOrders.get(order2.Id).Order_Status__c);
    }

    @IsTest
    static void testOrderTotalUpdater() {
        Account accountRecord = createAccount();
        Product2 product = createProduct();
        AgriEdge_Order__c order1 = createOrder(accountRecord.Id, 'Pending', 'New');
        AgriEdge_Order__c order2 = createOrder(accountRecord.Id, 'Pending', 'New');

        insert new List<AgriEdge_OrderItem__c>{
            new AgriEdge_OrderItem__c(Name = 'Line 1', Order__c = order1.Id, Product__c = product.Id, Quantity__c = 2, Unit_Price__c = 25),
            new AgriEdge_OrderItem__c(Name = 'Line 2', Order__c = order1.Id, Product__c = product.Id, Quantity__c = 1, Unit_Price__c = 30)
        };

        Test.startTest();
        OrderTotalUpdater.updateOrderTotal(new Set<Id>{ order1.Id, order2.Id });
        Test.stopTest();

        Map<Id, AgriEdge_Order__c> refreshedOrders = new Map<Id, AgriEdge_Order__c>([
            SELECT Id, Total_Amount__c, Payment_Status__c
            FROM AgriEdge_Order__c
            WHERE Id IN :new Set<Id>{ order1.Id, order2.Id }
        ]);
        System.assertEquals(80, refreshedOrders.get(order1.Id).Total_Amount__c);
        System.assertEquals('Pending', refreshedOrders.get(order1.Id).Payment_Status__c);
        System.assertEquals(0, refreshedOrders.get(order2.Id).Total_Amount__c);
        System.assertEquals('Paid', refreshedOrders.get(order2.Id).Payment_Status__c);
    }

    @IsTest
    static void testSendOrderEmail() {
        Account accountRecord = createAccount();
        insert new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com',
            AccountId = accountRecord.Id
        );

        AgriEdge_Order__c orderRecord = createOrder(accountRecord.Id, 'Paid', 'Delivered');
        orderRecord.Total_Amount__c = 150;
        update orderRecord;

        Test.startTest();
        OrderEmailSender.sendOrderEmail(new Set<Id>{ orderRecord.Id });
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, emailInvocations);
    }

    @IsTest
    static void testAgriEdgeOrderShipmentHelper() {
        Account accountRecord = createAccount();
        AgriEdge_Order__c orderRecord = createOrder(accountRecord.Id, 'Pending', 'Processing');

        Test.startTest();
        AgriEdgeOrderShipmentHelper.processOrderStatusChange(new List<AgriEdge_Order__c>{ orderRecord });
        Test.stopTest();

        List<AgriEdge_Shipment__c> shipments = [
            SELECT Id, Order__c, Status__c
            FROM AgriEdge_Shipment__c
            WHERE Order__c = :orderRecord.Id
        ];
        System.assertEquals(1, shipments.size());
        System.assertEquals('Pending', shipments[0].Status__c);
    }

    @IsTest
    static void testAgriEdgeOrderTriggerAndPaymentEmailTrigger() {
        Account accountRecord = createAccount();
        insert new Contact(
            FirstName = 'Paid',
            LastName = 'Customer',
            Email = 'paidcustomer@example.com',
            AccountId = accountRecord.Id
        );

        AgriEdge_Order__c orderRecord = createOrder(accountRecord.Id, 'Pending', 'New');

        Test.startTest();
        orderRecord.Payment_Status__c = 'Paid';
        update orderRecord;
        Test.stopTest();

        AgriEdge_Order__c refreshedOrder = [
            SELECT Order_Status__c
            FROM AgriEdge_Order__c
            WHERE Id = :orderRecord.Id
        ];
        System.assertEquals('Delivered', refreshedOrder.Order_Status__c);
    }

    @IsTest
    static void testOrderItemTrigger() {
        Account accountRecord = createAccount();
        Product2 product = createProduct();
        AgriEdge_Inventory__c inventory = new AgriEdge_Inventory__c(
            Name = 'Trigger Inventory',
            Product__c = product.Id,
            Stock_Quantity__c = 25,
            Reorder_Level__c = 5,
            Warehouse_Location__c = 'WH-1'
        );
        insert inventory;

        AgriEdge_Order__c orderRecord = createOrder(accountRecord.Id, 'Pending', 'New');

        Test.startTest();
        insert new AgriEdge_OrderItem__c(
            Name = 'Trigger Line',
            Order__c = orderRecord.Id,
            Product__c = product.Id,
            Quantity__c = 2,
            Unit_Price__c = 10
        );
        Test.stopTest();

        AgriEdge_Order__c refreshedOrder = [
            SELECT Order_Status__c, Total_Amount__c
            FROM AgriEdge_Order__c
            WHERE Id = :orderRecord.Id
        ];
        System.assertEquals('Processing', refreshedOrder.Order_Status__c);
        System.assertEquals(20, refreshedOrder.Total_Amount__c);
    }

    @IsTest
    static void testAgriEdgeOrderTriggerHelper() {
        AgriEdgeOrderTriggerHelper.isTriggerExecuted = false;
        Boolean flagBeforeExecution = AgriEdgeOrderTriggerHelper.isTriggerExecuted;
        AgriEdgeOrderTriggerHelper.isTriggerExecuted = true;
        System.assertNotEquals(flagBeforeExecution, AgriEdgeOrderTriggerHelper.isTriggerExecuted);
    }
}
