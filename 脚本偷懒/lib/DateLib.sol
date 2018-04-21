import "Strings.sol";

library DateLib {
    using Strings for *;
	uint32 constant SECONDOFDAY  = 86400;
	uint16 constant SECONDOFHOUR = 3600;
	uint8  constant SECONDOFMIN  = 60;

	struct DateTime {
		uint16 YYYY;
		uint8 MM;
		uint8 DD;
		uint8 HH;
		uint8 MI;
		uint8 SS;
	}

	/**
	 * @dev  check if the year is leap year
	 * @param year to be checked
	 * @return  comm year return 0 leap year return 1
	 */
	function leapYear(uint16 year) returns(uint8 r) {

		if( (year%4 == 0 && year%100 != 0) || (year%400 == 0) ) {

			r = 1;
		}
		else {
			r = 0;
		}
	}

	/**
	 * @dev  calc the days of the year
	 * @param year to be calculated
	 * @return  days of the year
	 */
	function daysOfYear(uint16 year) returns(uint16) {
		return (1 == leapYear(year))?366:365;
	}

	/**
	 * @dev  set the value of the DateTime
	 * @param dt DateTime to be set
	 * @param secs seconds from 1970-01-01 00:00:00
	 */
	function setDateTime(DateTime storage dt, uint secs) internal {

		if(secs == 0) {
			secs = now;
		}
		uint daysTotal = secs / SECONDOFDAY;
		uint16 curYear = 1970;
		uint leftDays = daysTotal;

		uint16 daysCurYear = daysOfYear(curYear);

		/* calc year */
		while(leftDays >= daysCurYear) {
			leftDays -= daysCurYear;
			curYear++;
			daysCurYear = daysOfYear(curYear);
		}
		dt.YYYY = curYear;


		/* calc month and day */
		for(uint8 i=0; i<13; ++i) {
			if(leftDays < daysOfDate(curYear,i)) {
				dt.MM = i;
				dt.DD = uint8(leftDays - daysOfDate(curYear,i-1)+1);
				break;
			}
		}

		/* calc time */
		uint32 leftSeconds = uint32(secs % SECONDOFDAY);
		/* chinese time=UTC+8 */
		dt.HH = uint8(leftSeconds / SECONDOFHOUR) + 8;
    //dt.HH = uint8(leftSeconds / SECONDOFHOUR);
		dt.MI = uint8((leftSeconds % SECONDOFHOUR) / SECONDOFMIN);
		dt.SS = uint8(leftSeconds % SECONDOFMIN);
	}

	/**
	 * @dev calc the days of the date
	 * @param year the year like 2016
	 * @param month the month June is 6
	 * @return days of the date
	 */
	function daysOfDate(uint16 year, uint8 month) returns(uint) {

		//days table of months for comm year and leap year
		uint16[13][2] memory mon_yday = [[0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],
							       [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]];
        return mon_yday[leapYear(year)][month];
	}

	function getCurSeconds(DateTime storage dt) internal returns(uint) { return now; }
	function year(DateTime storage dt) internal constant returns(uint16) { return dt.YYYY; }
	function month(DateTime storage dt) internal constant returns(uint8) { return dt.MM; }
	function day(DateTime storage dt) internal constant returns(uint8) { return dt.DD; }
	function hour(DateTime storage dt) internal constant returns(uint8) { return dt.HH; }
	function minute(DateTime storage dt) internal constant returns(uint8) { return dt.MI; }
	function second(DateTime storage dt) internal constant returns(uint8) { return dt.SS; }


	/**
	 * @dev  get the value of DateTime
	 * @param dt DateTime
	 * @return y:year,m:mouth,d:day,h:hour,min:minute,s:seconds
	 */
	function dateTime(DateTime storage dt) internal constant returns(uint16 y, uint8 m, uint8 d, uint8 h, uint8 min, uint8 s) {
		y = year(dt);
		m = month(dt);
		d = day(dt);
		h = hour(dt);
		min = minute(dt);
		s = second(dt);
	}

	/**
	 * @dev  get the string value of DateTime
	 * @param dt DateTime
	 * @return string value of the DateTime format:YYYY-MM-DD HH:MI:SS
	 */
	function dateTime_str(DateTime storage dt) internal constant returns(string datetime) {
	    var yyyy = Strings.bytes32ToString(Strings.uintToBytes(dt.YYYY));
	    var mm = Strings.bytes32ToString(Strings.uintToBytes(dt.MM));
	    var dd = Strings.bytes32ToString(Strings.uintToBytes(dt.DD));
	    var hh = Strings.bytes32ToString(Strings.uintToBytes(dt.HH));
	    var mi = Strings.bytes32ToString(Strings.uintToBytes(dt.MI));
	    var ss = Strings.bytes32ToString(Strings.uintToBytes(dt.SS));

	    datetime = yyyy.toSlice().concat("-".toSlice());

	    if(dt.MM < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(mm.toSlice());
	    datetime = datetime.toSlice().concat("-".toSlice());
	    if(dt.DD < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(dd.toSlice());
	    datetime = datetime.toSlice().concat(" ".toSlice());
	    if(dt.HH < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(hh.toSlice());
	    datetime = datetime.toSlice().concat(":".toSlice());
	    if(dt.MI < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(mi.toSlice());
	    datetime = datetime.toSlice().concat(":".toSlice());
	    if(dt.SS < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(ss.toSlice());
	}

	/**
	 * @dev  get the timestamp value of DateTime
	 * @param dt DateTime
	 * @return string value of the DateTime format:YYYYMMDDHHMISS
	 */
	function timestamp(DateTime storage dt) internal constant returns(string datetime) {
	    var yyyy = Strings.bytes32ToString(Strings.uintToBytes(dt.YYYY));
	    var mm = Strings.bytes32ToString(Strings.uintToBytes(dt.MM));
	    var dd = Strings.bytes32ToString(Strings.uintToBytes(dt.DD));
	    var hh = Strings.bytes32ToString(Strings.uintToBytes(dt.HH));
	    var mi = Strings.bytes32ToString(Strings.uintToBytes(dt.MI));
	    var ss = Strings.bytes32ToString(Strings.uintToBytes(dt.SS));

	    datetime = yyyy;

	    if(dt.MM < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(mm.toSlice());
	    if(dt.DD < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(dd.toSlice());
	    if(dt.HH < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(hh.toSlice());
	    if(dt.MI < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(mi.toSlice());
	    if(dt.SS < 10) {
	        datetime = datetime.toSlice().concat("0".toSlice());
	    }
	    datetime = datetime.toSlice().concat(ss.toSlice());
	}

	/**
	 * @dev  compare 2 DateTimes
	 * @param lv DateTime left value
	 * @param rv DateTime right value
	 * @return Returns a positive number if rv comes after lv,
	 *         a negative number if it comes before,
	 *         or zero if the value of the two DateTime are equal.
	 *         notice: the return value is not really represent the diff of the to DateTime
	 */
	function earlier(DateTime storage lv, DateTime storage rv) internal returns(int) {

	    /* ignore leap year here is a good idea */
	    uint lDaysOfYear = uint(year(lv) * 365);
	    uint rDaysOfYear = uint(year(rv) * 365);

	    uint lDaysOfMon = daysOfDate(year(lv), month(lv));
	    uint rDaysOfMon = daysOfDate(year(rv), month(rv));

	    uint lDays = lDaysOfYear + lDaysOfMon + day(lv);
	    uint rDays = rDaysOfYear + rDaysOfMon + day(rv);
	    uint lSeconds = lDays*SECONDOFDAY + hour(lv)*SECONDOFHOUR + minute(lv)*SECONDOFMIN + second(lv);
	    uint rSeconds = rDays*SECONDOFDAY + hour(rv)*SECONDOFHOUR + minute(rv)*SECONDOFMIN + second(rv);

	    return int(rSeconds - lSeconds);
	}

}
