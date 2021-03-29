module RolifyAdmin
  ROLES.each {|role_name| define_method("#{role_name}?") { has_role? role_name.to_sym } }
end
