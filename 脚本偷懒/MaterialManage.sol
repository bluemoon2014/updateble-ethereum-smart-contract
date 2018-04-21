import "./Upgradeable.sol";
import "./MaterialManageStorage.sol";
import "./ContractAddressManage.sol";

//用于存储数据
contract MaterialManage is Upgradeable,ContractAddressManage,MaterialManageStorage{
    function initialize(){
        throw;
    }
}
