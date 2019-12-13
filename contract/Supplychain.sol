pragma solidity >=0.4.22 <0.6.0;
// pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;
contract Supplychain{
    struct Company{
        string name;
        address ad;
        uint creditRating;
    }

    struct Receipt{
        uint id;
        address owner;
        address client;
        uint amount;
        uint start;
        uint ddl;
        // uint rank;
        bool usedLoan;
        string description;
    }
    
    //等待签署的应收款单据
    mapping(uint => Receipt) public pending;

    Company[]  companys;
    Company[] public banks;
    
    //公司到应收帐款的映射
    mapping(address => Receipt[]) public receipts;
    
    //应收款单据编号 1,2,3,...
    uint rid;
    
    event ReceiptIssued(address owner, string desc);
    event ReceiptSigned(address who, string desc);
    event Transfered(address fromadd, address toadd,uint amount,string desc);
    event Loaned(address who, uint amount,string desc);
    event pay(address fromadd,address toadd,uint amount, string desc);
    
    constructor() public {
        rid = 1;
    }
    

    
    function AddBank(string _name,address _ad)public returns(bool){
        banks.push(Company(_name,_ad,0));
        return true;
    }
    
    //公司发起应收款单据
    function IssueReceipt(address owner, address client, uint amount,uint ddl) public returns(uint id_){
        require(msg.sender==owner);
        pending[rid] = Receipt(rid,msg.sender,client,amount,0,now+ddl,false,"");
        id_ = rid;
        rid++;
        emit ReceiptIssued(owner,"receipt Issued");
    }
    
    //客户签署应收款单据
    function SignReceipt(uint _id)public returns(bool){
        Receipt r = pending[_id];
        //签署人必须是该单据的client
        require(r.client == msg.sender,"your don't have permission to sign this receipt.");
        //单据未到期
        require(now < r.ddl);
        receipts[r.owner].push(Receipt(r.id, r.owner, r.client,r.amount,now,r.ddl,false,""));
        emit ReceiptIssued(msg.sender,"receipt signed");
        return true;
    }
    
    // function AddReceipt(address owner, address client, uint amount)public returns(uint id_){
    //     receipts[owner].push(Receipt(rid,owner,client,amount,now,now+1000000,false,""));
    //     id_ = rid;
    //     rid++;
    // }
    
    function TransferTo(uint receiptid, address to, uint amount) public returns(uint id_){
        Receipt storage senderReceipt;
        for (uint i = 0; i < receipts[msg.sender].length;i++)
        {
            if (receipts[msg.sender][i].id==receiptid)
            {
                senderReceipt = receipts[msg.sender][i];
                break;
            }
            require(i != receipts[msg.sender].length - 1,"no such receipt id.");
        }

        require(senderReceipt.amount >= amount && amount > 0);
        //转移账款
        senderReceipt.amount -=amount;
        receipts[to].push(Receipt(rid,to, senderReceipt.client, amount, now,senderReceipt.ddl,false,""));
        id_ = rid;
        rid++;
        Transfered(msg.sender, to, amount,"transfer successfully");
    }
    
    function MakeLoan(address loanTo, uint loanAmount, uint receiptid) public returns(bool){
        //放贷款必须是银行
        uint  cnt = 0;
        uint i;
        for ( i = 0; i < banks.length; i++)
        {
            if (banks[i].ad == msg.sender)
            {
                cnt++;
            }
        }
        require(cnt == 1);
        
        //找到应收款单据
        Receipt storage r;
        for (i = 0; i < receipts[loanTo].length;i++)
        {
            if (receipts[loanTo][i].id==receiptid)
            {
                r = receipts[loanTo][i];
                break;
            }
            require(i != receipts[msg.sender].length - 1,"no such receipt id.");
        }
        
        //false 说明该单据已经被用来贷款了
        require(r.usedLoan==false,"the receipt has been used for loan");
        require(r.amount >=loanAmount);
        r.usedLoan = true;
        Loaned(loanTo,loanAmount,"loaned successfully.");
        return true;
    }
    
    function PayForReceipt(address owner, uint amount,uint receiptid) public returns(bool){
        Receipt storage r;
        uint i;
        for (i = 0; i < receipts[owner].length;i++)
        {
            if (receipts[owner][i].id==receiptid)
            {
                r = receipts[owner][i];
                break;
            }
            require(i != receipts[msg.sender].length - 1,"no such receipt id.");
        }
        
        require(r.client == msg.sender,"sender doesn't match receipt's client");
        require(r.amount >= amount,"payment exceeds receipt'amount");
        r.amount -= amount;
        if(r.amount > 0)
            return true;
        for(;i<receipts[owner].length - 1;i++)
        {
            receipts[owner][i] = receipts[owner][i+1];
        }
        delete receipts[owner][i];
        receipts[owner].length--;
        pay(msg.sender, owner, amount,"pay for receipt successfully.");
        return true;
    }
}

