import time
from datetime import datetime
def get_now_time(format_time='%Y-%m-%d %H:%M:%S.%f'):
    now_time=datetime.now()
    return now_time.strftime(format_time)[:-3]

def get_now_date(format_time='%Y-%m-%d'):
    now_time=datetime.now()
    return now_time.strftime(format_time)

def get_now_time_ms():
    t = time.time()
    return int(round(t * 1000))

def time_diff(timestr1, timestr2):
    if timestr1 is None or timestr2 is None:
        return None

    def parse_time(timestr):
        try:
            return datetime.strptime(timestr, "%Y-%m-%d %H:%M:%S.%f")
        except ValueError:
            try:
                return datetime.strptime(timestr, "%Y-%m-%d %H:%M:%S")
            except ValueError as e:
                print(f"无法解析时间格式: {timestr}, 错误: {e}")
                raise e

    timestamp1 = parse_time(timestr1)
    timestamp2 = parse_time(timestr2)

    if timestamp1 > timestamp2:
        return '-' + str(timestamp1 - timestamp2)
    else:
        return str(timestamp2 - timestamp1)

def time_to_millisecond(time_str):
    dt_obj = datetime.strptime(time_str, "%Y-%m-%d")
    timestamp = dt_obj.timestamp()  # timestamp is in seconds
    millisecond = timestamp * 1000  # convert to milliseconds
    return int(millisecond)

def millisecond_to_time(millisecond):
    timestamp = millisecond / 1000  # convert to seconds
    dt_obj = datetime.fromtimestamp(timestamp)
    return dt_obj.strftime("%Y-%m-%d %H:%M:%S")

def millisecond_to_time_date(millisecond):
    timestamp = millisecond / 1000  # convert to seconds
    dt_obj = datetime.fromtimestamp(timestamp)
    return dt_obj.strftime("%Y-%m-%d")

def fill_date(date_str):
    current_time = time.localtime()
    current_year = current_time.tm_year
    current_month = current_time.tm_mon

    if date_str.startswith('-'):
        date_str = date_str[1:]
    parts = date_str.split('-')
    if len(parts) == 2:  # Format is mm-dd
        date_str = f"{current_year}-{date_str}"
    elif len(parts) == 1:  # Format is dd (assuming current year and month)
        date_str = f"{current_year}-{current_month:02d}-{date_str}"
    return date_str

def fill_time(time_str, use_max):
    if time_str.endswith(':'):
        time_str = time_str[:-1]
    parts = time_str.split(':')
    if len(parts) == 2:  # Format is HH:MM
        if use_max:
            time_str = f"{time_str}:59"
        else:
            time_str = f"{time_str}:00"
    elif len(parts) == 1:  # Format is HH
        if use_max:
            time_str = f"{time_str}:59:59"
        else:
            time_str = f"{time_str}:00:00"
    return time_str

#支持缺省的时间表示 假设当前的时间为2024-08-15
# -14 表示 2024-08-14 00:00:00（use_max=False） 或者2024-08-14 23:59:59 (use_max=True)
# 14:30 表示 2024-08-15 14:30:00（use_max=False） 或者2024-08-15 14:30:59 (use_max=True)
# 14: 表示 2024-08-15 14:00:00（use_max=False） 或者2024-08-15 14:59:59 (use_max=True)
# 08-14 表示 2024-08-14 00:00:00（use_max=False） 或者2024-08-14 23:59:59 (use_max=True)
# -13 12: 表示 2024-08-13 12:00:00（use_max=False） 或者2024-08-13 12:59:59 (use_max=True)
def convert_to_unix_second(time_str, use_max=False):
    if time_str.endswith(':'):
        time_str = time_str[:-1]
    if '.' in time_str:
        time_str = time_str.split('.')[0]
    parts = time_str.split()
    if len(parts) == 1:
        part = parts[0]
        if '-' in part:  # It's a date
            date_str = fill_date(part)
            if use_max:
                time_str = f"{date_str} 23:59:59"
            else:
                time_str = f"{date_str} 00:00:00"
        elif ':' in part:  # It's a time
            date_str = time.strftime("%Y-%m-%d")
            time_str = fill_time(part, use_max)
            time_str = f"{date_str} {time_str}"
    elif len(parts) == 2:
        date_part, time_part = parts
        date_str = fill_date(date_part)
        time_str = fill_time(time_part, use_max)
        time_str = f"{date_str} {time_str}"
    else:
        raise ValueError("Unsupported time string format {time_str}")

    time_struct = time.strptime(time_str, "%Y-%m-%d %H:%M:%S")
    timestamp = time.mktime(time_struct)
    return timestamp

def convert_to_unix_millisecond(time_str, use_max=False):
    return convert_to_unix_second(time_str, use_max) * 1000

