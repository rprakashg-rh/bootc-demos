package access.policy

default allow = false

# Only these groups are allowed login
allowed_groups = {
  "wheel",
  "ops"
}

# Time-based access window
within_business_hours {
  t := time.now_ns() / 1000000000
  hour := time.hour(t)
  hour >= 9
  hour < 17
}

allow {
  # get the groups the user is member of
  some g
  g := input.groups[_]
  allowed_groups[g]
  within_business_hours
}
