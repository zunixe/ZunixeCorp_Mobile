import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zunixe_corp_mobile/features/auth/domain/auth_session.dart';

/// User versi domain — terlepas dari SDK Supabase.
///
/// UI hanya boleh mengenal tipe ini, bukan `supabase.User`.
class AppUser {
  final String id;
  final String? email;
  final String displayName;

  const AppUser({
    required this.id,
    this.email,
    required this.displayName,
  });

  factory AppUser.fromSupabase(User user) => AppUser(
        id: user.id,
        email: user.email,
        displayName: displayNameFor(user),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName;

  @override
  int get hashCode => Object.hash(id, email, displayName);
}
