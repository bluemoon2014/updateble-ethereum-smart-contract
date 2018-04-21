import "./Upgradeable.sol";
import "./AuthManageStorage.sol";
import "./ContractAddressManage.sol";

//用于存储数据
contract AuthManage is Upgradeable,ContractAddressManage,AuthManageStorage{
    function initialize(){
        throw;
    }
}
