import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can create new order with valid inputs",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("trade-grid", "create-order", [
        types.uint(1), // commodity id
        types.uint(100), // quantity
        types.uint(50)  // price
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectUint(1);
  },
});

Clarinet.test({
  name: "Ensure order creation fails with invalid inputs",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("trade-grid", "create-order", [
        types.uint(1),
        types.uint(0), // invalid quantity
        types.uint(50)
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectErr(102); // err-invalid-quantity
  },
});

Clarinet.test({
  name: "Ensure can cancel active order only",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("trade-grid", "create-order", [
        types.uint(1),
        types.uint(100),
        types.uint(50)
      ], wallet_1.address),
      Tx.contractCall("trade-grid", "cancel-order", [
        types.uint(1)
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk();
  },
});
