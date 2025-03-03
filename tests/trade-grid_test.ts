import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can create new order with valid inputs and sufficient balance",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    // First mint some tokens
    let block = chain.mineBlock([
      Tx.contractCall("commodities", "mint", [
        types.uint(1000),
        types.principal(wallet_1.address)
      ], wallet_1.address),
      Tx.contractCall("trade-grid", "create-order", [
        types.uint(1),
        types.uint(100),
        types.uint(50)
      ], wallet_1.address)
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk().expectUint(1);
  },
});

Clarinet.test({
  name: "Ensure complete trade flow works with token transfers",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    let block = chain.mineBlock([
      // Setup
      Tx.contractCall("commodities", "mint", [
        types.uint(1000),
        types.principal(wallet_1.address)
      ], wallet_1.address),
      // Create and execute trade
      Tx.contractCall("trade-grid", "create-order", [
        types.uint(1),
        types.uint(100),
        types.uint(50)
      ], wallet_1.address),
      Tx.contractCall("trade-grid", "execute-trade", [
        types.uint(1)
      ], wallet_2.address)
    ]);
    
    assertEquals(block.receipts.length, 3);
    block.receipts[2].result.expectOk();
  },
});
