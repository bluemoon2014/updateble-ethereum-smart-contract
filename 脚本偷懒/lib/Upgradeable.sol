import "UpgradeSupport.sol";
/*import "LogSupport.sol";*/

/*
 可升级的可约
 */
contract Upgradeable is UpgradeSupport{

    function(){

        // get signature return size
        bytes4 sig;
        assembly { sig := calldataload(0) }
        uint return_data_size = 0;
        return_data_size = sizes[sig];
        address targetAddr = targetContract;

        // get calldatasize
        uint call_data_size;
        assembly{
            call_data_size := calldatasize
        }

        //get actual return size
        uint actual_return_size = return_data_size;
        if(  actual_return_size ==0  ){

        }else if(actual_return_size == uint(SizeType.ST_CUSTOM) ){
            assembly{
                actual_return_size := calldataload(add(o_code,0x04))
            }
        }else if(actual_return_size == uint(SizeType.ST_STRING_32) ){
            actual_return_size = 32+ 32*2;
        }else if(actual_return_size == uint(SizeType.ST_STRING_320) ){
            actual_return_size = 320+ 32*2;
        }else if(actual_return_size == uint(SizeType.ST_STRING_3200) ){
            actual_return_size = 3200+ 32*2;
        }else if(actual_return_size == uint(SizeType.ST_STRING_32000) ){
            actual_return_size = 32000+ 32*2;
        }

        // malloc max mem size
        uint malloc_mem_size;
        if( actual_return_size> call_data_size ){
            malloc_mem_size = actual_return_size;
        }else{
            malloc_mem_size = call_data_size;
        }


        // Make the call
        uint r;
        uint o_code;

         assembly {
          o_code := mload(0x40)
          mstore(0x40,add(o_code,malloc_mem_size)) // Set storage pointer to empty space
          calldatacopy(o_code, 0, calldatasize)
          r := delegatecall(sub(gas,10000), targetAddr, o_code, call_data_size, o_code, actual_return_size)
        }

        // Throw if the call failed
        if (r != 1) { throw;}

        // Pass on the return value
         assembly {
          return(add(o_code,0x0), actual_return_size)
        }
    }
}
