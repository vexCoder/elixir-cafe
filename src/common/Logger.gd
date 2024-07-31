extends Node

enum Level {
    INFO,
    WARNING,
    ERROR,
}

var file: FileAccess
var dir = "user://logs"

signal log_updated(data: Dictionary)

func access_log():
    DirAccess.make_dir_recursive_absolute(dir)

    var filename = Time.get_date_string_from_system() + ".log"
    var file_path = dir + '/' + filename

    var file_check = FileAccess.open(file_path, FileAccess.READ)
    if not file_check:
        file_check = FileAccess.open(file_path, FileAccess.WRITE)
    
    file_check.close()

    return FileAccess.open(file_path, FileAccess.READ_WRITE)

func _ready():
    file = access_log()
    file.seek_end()
    file.flush()
    Logger.i("Logger initialized")

func get_level_string(level: Level):
    match level:
        Level.INFO:
            return "INFO"
        Level.WARNING:
            return "WARNING"
        Level.ERROR:
            return "ERROR"

func _write_log(
    level: Level, 
    message: Variant,
    message2: Variant = null,
    message3: Variant = null,
    message4: Variant = null,
    message5: Variant = null,
    message6: Variant = null,
    message7: Variant = null,
    message8: Variant = null,
    message9: Variant = null,
):
    var unix = Time.get_unix_time_from_system()
    var version = Global.version
    var stack = get_stack()
    
    var messages = [
        message,
        message2,
        message3,
        message4,
        message5,
        message6,
        message7,
        message8,
        message9,
    ]

    var msg = ''
    for v in range(messages.size()):
        var m = messages[v]
        
        if m == null:
            continue

        if v == 0:
            msg += str(m)
        else:
            msg += " " + str(m)

    var dict = {
        "level": level,
        "time": unix,
        "version": version,
        "message": msg,
        "stack": stack,
    }

        
    var format_string = "[{level}] {time} {version} {message}"

    print(format_string.format({
        "level": get_level_string(level),
        "time": Time.get_date_string_from_unix_time(unix) + " " + Time.get_time_string_from_unix_time(unix),
        "version": version,
        "message": msg,
    }))

    if file and file.is_open():
        file.seek_end()
        file.store_line(JSON.stringify(dict))
        file.flush()
        log_updated.emit(dict)

func i(
    message: Variant,
    message2: Variant = null,
    message3: Variant = null,
    message4: Variant = null,
    message5: Variant = null,
    message6: Variant = null,
    message7: Variant = null,
    message8: Variant = null,
    message9: Variant = null,
):
    _write_log(
        Level.INFO, 
        message,
        message2,
        message3,
        message4,
        message5,
        message6,
        message7,
        message8,
        message9,
    )

func w(
    message: Variant,
    message2: Variant = null,
    message3: Variant = null,
    message4: Variant = null,
    message5: Variant = null,
    message6: Variant = null,
    message7: Variant = null,
    message8: Variant = null,
    message9: Variant = null,
):
    _write_log(
        Level.WARNING, 
        message,
        message2,
        message3,
        message4,
        message5,
        message6,
        message7,
        message8,
        message9,
    )

func e(
    message: Variant,
    message2: Variant = null,
    message3: Variant = null,
    message4: Variant = null,
    message5: Variant = null,
    message6: Variant = null,
    message7: Variant = null,
    message8: Variant = null,
    message9: Variant = null,
):
    _write_log(
        Level.ERROR, 
        message,
        message2,
        message3,
        message4,
        message5,
        message6,
        message7,
        message8,
        message9,
    )

func get_logs():
    if file and file.is_open():
        file.seek(0)
        var logs = []
        while not file.eof_reached():
            var line = file.get_line()
            var json = JSON.new()
            var res = json.parse(line)
            if res == OK:
                logs.append(json.data)
        return logs
    return []
