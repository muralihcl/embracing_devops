class create_user (
) {
  contain 'create_user::group'
  contain 'create_user::user'
  Class['create_user::group'] -> Class['create_user::user']
}
