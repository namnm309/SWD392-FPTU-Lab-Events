enum UserRole {
  student('Student'),
  labManager('Lab Manager'),
  admin('Admin');

  const UserRole(this.displayName);
  final String displayName;
}
