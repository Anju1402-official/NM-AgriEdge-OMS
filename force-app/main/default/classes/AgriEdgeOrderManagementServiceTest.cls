@IsTest
private class AgriEdgeOrderManagementServiceTest {
    @IsTest
    static void syncsOrderTotalsAndInventory() {
        Account customer = new Account(Name = 'AgriEdge Test Customer');
        insert customer;

        Product2 product = new Product2(
            Name = 'Hybrid Seeds',
            ProductCode = 'SEED-100',
            IsActive = true
        );
        insert product;

        AgriEdge_Inventory__c inventory = new AgriEdge_Inventory__c(
            Name = 'Seed Inventory',
            Product__c = product.Id,
            Stock_Quantity__c = 100,
            Reorder_Level__c = 10,
            Warehouse_Location__c = 'Warehouse A'
        );
        insert inventory;

        AgriEdge_Order__c orderRecord = new AgriEdge_Order__c(
            Customer__c = customer.Id,
            Order_Status__c = 'New',
            Order_Date__c = System.now(),
            Payment_Status__c = 'Pending',
            Shipping_Address__c = 'Field Unit 7'
        );
        insert orderRecord;

        Test.startTest();
        AgriEdge_OrderItem__c item = new AgriEdge_OrderItem__c(
            Name = 'Line 1',
            Order__c = orderRecord.Id,
            Product__c = product.Id,
            Quantity__c = 5,
            Unit_Price__c = 20
        );
        insert item;
        Test.stopTest();

        AgriEdge_Order__c insertedOrder = [
            SELECT Total_Amount__c, Discounted_Total__c
            FROM AgriEdge_Order__c
            WHERE Id = :orderRecord.Id
        ];
        AgriEdge_Inventory__c updatedInventory = [
            SELECT Stock_Quantity__c, Stock_Status__c
            FROM AgriEdge_Inventory__c
            WHERE Id = :inventory.Id
        ];

        System.assertEquals(100, insertedOrder.Total_Amount__c);
        System.assertEquals(90, insertedOrder.Discounted_Total__c);
        System.assertEquals(95, updatedInventory.Stock_Quantity__c);
        System.assertEquals('Sufficient', updatedInventory.Stock_Status__c);

        item.Quantity__c = 8;
        update item;
        delete item;

        insertedOrder = [
            SELECT Total_Amount__c
            FROM AgriEdge_Order__c
            WHERE Id = :orderRecord.Id
        ];
        updatedInventory = [
            SELECT Stock_Quantity__c
            FROM AgriEdge_Inventory__c
            WHERE Id = :inventory.Id
        ];

        System.assertEquals(0, insertedOrder.Total_Amount__c);
        System.assertEquals(100, updatedInventory.Stock_Quantity__c);
    }

    @IsTest
    static void shipmentValidationRequiresTrackingNumber() {
        Account customer = new Account(Name = 'Shipment Customer');
        insert customer;

        AgriEdge_Order__c orderRecord = new AgriEdge_Order__c(
            Customer__c = customer.Id,
            Order_Status__c = 'Delivered',
            Order_Date__c = System.now(),
            Payment_Status__c = 'Paid',
            Shipping_Address__c = 'Central Depot'
        );
        insert orderRecord;

        AgriEdge_Shipment__c shipment = new AgriEdge_Shipment__c(
            Name = 'Shipment 1',
            Order__c = orderRecord.Id,
            Carrier__c = 'DHL',
            Status__c = 'Delivered'
        );

        Database.SaveResult saveResult = Database.insert(shipment, false);
        System.assertEquals(false, saveResult.isSuccess());
        System.assert(saveResult.getErrors()[0].getMessage().contains('Tracking Number is required'));
    }
}
