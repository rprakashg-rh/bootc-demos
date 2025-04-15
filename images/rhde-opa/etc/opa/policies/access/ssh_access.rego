package access.policy

default allow := false

# Define start and end time in "HH:MM" 24-hour format
start := 9
end := 17

get_time = {"hour": hour, "minute": minute} if {
    t := time.now_ns()
    ts := time.clock([t, "America/Los_Angeles"])
    hour := ts[0]
    minute := ts[1]
}

# Only these groups are allowed login
allowed_groups := {
	"wheel",
	"ops",
}

allow if {
	user := input.user
    user == "admin"
}

allow if {
	some group

	groups := split(input.groups, ",")
	group = groups[_]
	group == allowed_groups[_]
    
    t := get_time
    t.hour >= start
    t.hour <= end
}