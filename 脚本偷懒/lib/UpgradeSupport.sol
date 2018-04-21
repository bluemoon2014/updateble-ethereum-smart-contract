//import "LogSupport.sol";

/**
 可升级的可约
 */
contract UpgradeSupport {
    mapping(bytes4=>uint32) sizes;
    address targetContract;
    address owner;

    enum SizeType { ST_NONE, ST_CUSTOM, ST_STRING_32, ST_STRING_320,ST_STRING_3200,ST_STRING_32000}

    function UpgradeSupport(){
        owner = msg.sender;
    }

    /**
     * This function is called using delegatecall from the dispatcher when the
     * target contract is first initialized. It should use this opportunity to
     * insert any return data sizes in _sizes, and perform any other upgrades
     * necessary to change over from the old contract implementation (if any).
     *
     * Implementers of this function should either perform strictly harmless,
     * idempotent operations like setting return sizes, or use some form of
     * access control, to prevent outside callers.
     */
    function initialize();

    /**
     * Performs a handover to a new implementing contract.
     */
    function update(address newAddress){
        if(msg.sender != owner) throw;
        targetContract = newAddress;
        //LogMessage("update ok");
        targetContract.delegatecall(bytes4(sha3("initialize()")));
    }
}
