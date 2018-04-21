/**
 * 提供交易类底层结构
 * 提供数据存储接口
 */
contract AuthManageStorage{

string cancel = "CANCEL"; //无效状态
string normal = "NORMAL"; //有效状态
mapping (uint => string)lolo;
//=========================用户信息======begin==================================
    //用户信息结构
    struct AccInfo{
        uint accId;//区块链自动生成
        string accCode;//用户CODE
        string account;//账号
        string userName;//账户名
        string password;//账户密码
        string accNo;//工号
        string companyCode;//公司ID
        string deptCode;//部门CODE
        string positionCode;//岗位CODE
        string roleCode;//角色code
        string urlCode;//菜单编号，多个用|分割
        string unBindUrlCode;//解绑的菜单编号，多个用|分割
        string email; //邮箱
        string mobile;//手机
        string enabled;//是否禁用 0：禁用；1：不禁用
        string tradeNo;//凭据号,开发者需要保证其唯一，与业务系统关联
        string hdAddress; //区块链账户地址，即公钥地址
        string privateKey;  //区块链账户私钥，私钥(已加密)
        string metadata;//自定义字段
        uint created; //记录区块链时间now
        uint lastModifyTime; //最后修改时间now
        string status;//当前记录的状态，默认：normal，已删除为：cancel
    }
    //*****账户mapping********************begin********************
    mapping(string=>AccInfo) accs;  //accCode=>AccInfo()
    mapping(string=>string) accUserNames;//userName=>accCode
    mapping(string=>string) accNos; // accNo=>accCode
    mapping(string=>string) accAdds;//hdAddress=>accCode
    string[] accCodes;
    //*****账户mapping********************end********************
//=========================用户信息======begin==================================


//=========================部门信息======begin==================================
  //部门信息
  struct DeptInfo{
    uint deptId;//区块链自动生成
    string deptCode;//部门CODE
    string parentCode; //上级Code
    string companyCode;//公司Code
    string depName;//部门名称
    string metadata;//备注
    string urlCode;//菜单编号，多个用|分割
    string unBindUrlCode;//解绑的菜单编号，多个用|分割
    uint created; //记录区块链时间now
    uint lastModifyTime; //最后修改时间now
    string status; //标记信息是否可用，CANCEL为不可用
  }
  mapping(string=>DeptInfo) deptInfos;  //deptCode=>DeptInfo()
  string[] deptCodes;
//=========================部门信息======end==================================

//=========================岗位信息======begin==================================
  //岗位信息
  struct PositionInfo{
    uint positionId;//区块链自动生成
    string positionCode;//岗位CODE
    string positionName;//岗位名称
    string companyCode; //公司Code
    string deptCode;  //部门Code
    string parentCode; //上级Code
    string urlCode;//菜单编号，多个用|分割
    string unBindUrlCode;//解绑的菜单编号，多个用|分割
    string metadata;//备注
    uint created; //记录区块链时间now
    uint lastModifyTime; //最后修改时间
    string status; //标记信息是否可用，CANCEL为不可用
  }
  //*****岗位信息mapping********************begin********************
  mapping(string=>PositionInfo) positions;  //positionCode=>PositionInfo()
  mapping(uint=>string) positionCodes; //positionCode=>positionCodes
  string[] positionCodeIds;
  //*****岗位信息mapping********************end********************
//=========================岗位信息======end==================================

//=========================角色信息======begin==================================
  struct RoleInfo{
    uint roleId;//区块链自动生成
    string roleCode;//角色CODE
    string companyCode; //部门Code
    string urlCode;//菜单编号，多个用|分割
    string unBindUrlCode;//解绑的菜单编号，多个用|分割
    string parentCode;//上级Code
    string roleName;//角色名称
    string roleType;//类型
    string enabled;//是否启用 0：禁用；1：不禁用
    string metadata;//备注
    uint created; //记录区块链时间now
    uint lastModifyTime; //最后修改时间
    string status; //标记信息是否可用，CANCEL为不可用
  }
  //*****角色信息mapping********************begin********************
  mapping(string=>RoleInfo) roles;  //roleCode=>RoleInfo()
  mapping(uint=>string) roleCodes; //roleCode=>roleCodes
  string[] roleCodesIds;
  //*****角色信息mapping********************end********************
  //=========================角色信息======end==================================


  //=========================菜单（url）信息======begin==================================
    //菜单（url）信息
    struct UrlInfo{
      uint urlId;//区块链自动生成
      string urlCode;//CODE
      string parentCode;//上级Code
      string systemCode;//系统Code
      string companyCode; //公司ID
      string name;//名称
      string url;//地址
      string metadata;//备注
      string createUser;//创建人
      uint created; //记录区块链时间now
      uint lastModifyTime; //最后修改时间
      string status; //标记信息是否可用，CANCEL为不可用
    }
    //*****菜单（url）信息mapping********************begin********************
    mapping(string=>UrlInfo) urls;  //roleCode=>UrlInfo()
    mapping(uint=>string) urlCodes; //urlCode=>urlCodes
    string[] urlCodesIds;
    //*****菜单（url）信息mapping********************end********************
    //=========================菜单（url）信息======end==================================

}
