#!/usr/bin/env bash
set -e

###############################################################################
# Config
###############################################################################

# Root of your Flutter app (adjust if needed)
BASE_DIR="E:/STUDY/Test_app"

cd "$BASE_DIR" || { echo "Directory not found: $BASE_DIR"; exit 1; }

echo "Creating folder structure inside: $BASE_DIR"

# Ensure lib exists (in case you haven't run flutter create yet)
mkdir -p "lib"

###############################################################################
# Core app & config
###############################################################################

mkdir -p \
  "lib/src" \
  "lib/src/config" \
  "lib/src/core/constants" \
  "lib/src/core/utils" \
  "lib/src/core/error" \
  "lib/src/core/network" \
  "lib/src/core/widgets" \
  "lib/src/core/services" \
  "lib/src/core/models" \
  "lib/src/routing" \
  "lib/src/features" \
  "lib/src/shared" \
  "assets/images" \
  "assets/icons" \
  "assets/fonts"

# Core app files
touch "lib/main.dart"
touch "lib/src/app.dart"

# Config
touch "lib/src/config/app_config.dart"
touch "lib/src/config/env.dart"
touch "lib/src/config/api_paths.dart"
touch "lib/src/config/app_theme.dart"
touch "lib/src/config/app_localization.dart"

# Routing
touch "lib/src/routing/app_router.dart"
touch "lib/src/routing/app_routes.dart"
touch "lib/src/routing/route_guard.dart"

# Core constants
touch "lib/src/core/constants/app_colors.dart"
touch "lib/src/core/constants/app_typography.dart"
touch "lib/src/core/constants/app_spacing.dart"
touch "lib/src/core/constants/app_assets.dart"
touch "lib/src/core/constants/app_roles.dart"

# Core utils
touch "lib/src/core/utils/validators.dart"
touch "lib/src/core/utils/formatters.dart"
touch "lib/src/core/utils/date_time_utils.dart"
touch "lib/src/core/utils/debouncer.dart"
touch "lib/src/core/utils/snackbar_utils.dart"

# Core error
touch "lib/src/core/error/exceptions.dart"
touch "lib/src/core/error/failures.dart"
touch "lib/src/core/error/error_mapper.dart"

# Core network
touch "lib/src/core/network/api_client.dart"
touch "lib/src/core/network/network_info.dart"
touch "lib/src/core/network/interceptors.dart"
touch "lib/src/core/network/api_response.dart"

# Core widgets
touch "lib/src/core/widgets/app_scaffold.dart"
touch "lib/src/core/widgets/app_button.dart"
touch "lib/src/core/widgets/app_text_field.dart"
touch "lib/src/core/widgets/app_dropdown.dart"
touch "lib/src/core/widgets/app_loading_indicator.dart"
touch "lib/src/core/widgets/app_empty_state.dart"
touch "lib/src/core/widgets/app_error_view.dart"
touch "lib/src/core/widgets/app_avatar.dart"
touch "lib/src/core/widgets/app_badge.dart"
touch "lib/src/core/widgets/app_bottom_nav_bar.dart"

# Core services
touch "lib/src/core/services/auth_service.dart"
touch "lib/src/core/services/storage_service.dart"
touch "lib/src/core/services/notification_service.dart"
touch "lib/src/core/services/deep_link_service.dart"
touch "lib/src/core/services/navigation_service.dart"

# Core models (global/shared models)
touch "lib/src/core/models/user_model.dart"
touch "lib/src/core/models/student_profile_model.dart"
touch "lib/src/core/models/teacher_profile_model.dart"
touch "lib/src/core/models/tuition_post_model.dart"
touch "lib/src/core/models/tuition_application_model.dart"
touch "lib/src/core/models/demo_session_model.dart"
touch "lib/src/core/models/match_model.dart"
touch "lib/src/core/models/chat_room_model.dart"
touch "lib/src/core/models/chat_message_model.dart"
touch "lib/src/core/models/notification_model.dart"
touch "lib/src/core/models/review_model.dart"
touch "lib/src/core/models/paginated_result.dart"

###############################################################################
# Feature: Auth (register, login, OTP, session)
###############################################################################

mkdir -p \
  "lib/src/features/auth/data/datasources" \
  "lib/src/features/auth/data/repositories" \
  "lib/src/features/auth/domain/entities" \
  "lib/src/features/auth/domain/repositories" \
  "lib/src/features/auth/domain/usecases" \
  "lib/src/features/auth/presentation/bloc" \
  "lib/src/features/auth/presentation/pages" \
  "lib/src/features/auth/presentation/widgets"

# Auth data
touch "lib/src/features/auth/data/datasources/auth_remote_data_source.dart"
touch "lib/src/features/auth/data/repositories/auth_repository_impl.dart"

# Auth domain
touch "lib/src/features/auth/domain/entities/auth_user.dart"
touch "lib/src/features/auth/domain/repositories/auth_repository.dart"
touch "lib/src/features/auth/domain/usecases/login_usecase.dart"
touch "lib/src/features/auth/domain/usecases/register_usecase.dart"
touch "lib/src/features/auth/domain/usecases/request_otp_usecase.dart"
touch "lib/src/features/auth/domain/usecases/verify_otp_usecase.dart"
touch "lib/src/features/auth/domain/usecases/get_current_user_usecase.dart"
touch "lib/src/features/auth/domain/usecases/logout_usecase.dart"

# Auth presentation
touch "lib/src/features/auth/presentation/bloc/auth_cubit.dart"
touch "lib/src/features/auth/presentation/pages/splash_page.dart"
touch "lib/src/features/auth/presentation/pages/onboarding_page.dart"
touch "lib/src/features/auth/presentation/pages/login_page.dart"
touch "lib/src/features/auth/presentation/pages/register_page.dart"
touch "lib/src/features/auth/presentation/pages/otp_verification_page.dart"
touch "lib/src/features/auth/presentation/widgets/login_form.dart"
touch "lib/src/features/auth/presentation/widgets/register_form.dart"
touch "lib/src/features/auth/presentation/widgets/otp_input_field.dart"

###############################################################################
# Feature: Dashboard / Home (role-based landing)
###############################################################################

mkdir -p \
  "lib/src/features/dashboard/presentation/pages" \
  "lib/src/features/dashboard/presentation/widgets" \
  "lib/src/features/dashboard/presentation/bloc"

touch "lib/src/features/dashboard/presentation/pages/dashboard_page.dart"
touch "lib/src/features/dashboard/presentation/pages/student_home_page.dart"
touch "lib/src/features/dashboard/presentation/pages/teacher_home_page.dart"
touch "lib/src/features/dashboard/presentation/pages/admin_home_page.dart"
touch "lib/src/features/dashboard/presentation/bloc/dashboard_cubit.dart"
touch "lib/src/features/dashboard/presentation/widgets/dashboard_header.dart"
touch "lib/src/features/dashboard/presentation/widgets/stats_overview_card.dart"

###############################################################################
# Feature: Profile (Student & Teacher)
###############################################################################

mkdir -p \
  "lib/src/features/profile/data/datasources" \
  "lib/src/features/profile/data/repositories" \
  "lib/src/features/profile/domain/entities" \
  "lib/src/features/profile/domain/repositories" \
  "lib/src/features/profile/domain/usecases" \
  "lib/src/features/profile/presentation/bloc" \
  "lib/src/features/profile/presentation/pages" \
  "lib/src/features/profile/presentation/widgets"

# Profile data
touch "lib/src/features/profile/data/datasources/profile_remote_data_source.dart"
touch "lib/src/features/profile/data/repositories/profile_repository_impl.dart"

# Profile domain
touch "lib/src/features/profile/domain/entities/student_profile.dart"
touch "lib/src/features/profile/domain/entities/teacher_profile.dart"
touch "lib/src/features/profile/domain/repositories/profile_repository.dart"
touch "lib/src/features/profile/domain/usecases/get_student_profile_usecase.dart"
touch "lib/src/features/profile/domain/usecases/update_student_profile_usecase.dart"
touch "lib/src/features/profile/domain/usecases/get_teacher_profile_usecase.dart"
touch "lib/src/features/profile/domain/usecases/update_teacher_profile_usecase.dart"

# Profile presentation
touch "lib/src/features/profile/presentation/bloc/profile_cubit.dart"
touch "lib/src/features/profile/presentation/pages/student_profile_page.dart"
touch "lib/src/features/profile/presentation/pages/teacher_profile_page.dart"
touch "lib/src/features/profile/presentation/pages/edit_student_profile_page.dart"
touch "lib/src/features/profile/presentation/pages/edit_teacher_profile_page.dart"
touch "lib/src/features/profile/presentation/widgets/profile_header.dart"
touch "lib/src/features/profile/presentation/widgets/profile_form_student.dart"
touch "lib/src/features/profile/presentation/widgets/profile_form_teacher.dart"

###############################################################################
# Feature: Tuition Posts (create, list, manage)
###############################################################################

mkdir -p \
  "lib/src/features/tuition_posts/data/datasources" \
  "lib/src/features/tuition_posts/data/repositories" \
  "lib/src/features/tuition_posts/domain/entities" \
  "lib/src/features/tuition_posts/domain/repositories" \
  "lib/src/features/tuition_posts/domain/usecases" \
  "lib/src/features/tuition_posts/presentation/bloc" \
  "lib/src/features/tuition_posts/presentation/pages" \
  "lib/src/features/tuition_posts/presentation/widgets"

# Tuition posts data
touch "lib/src/features/tuition_posts/data/datasources/tuition_posts_remote_data_source.dart"
touch "lib/src/features/tuition_posts/data/repositories/tuition_posts_repository_impl.dart"

# Tuition posts domain
touch "lib/src/features/tuition_posts/domain/entities/tuition_post.dart"
touch "lib/src/features/tuition_posts/domain/repositories/tuition_posts_repository.dart"
touch "lib/src/features/tuition_posts/domain/usecases/create_tuition_post_usecase.dart"
touch "lib/src/features/tuition_posts/domain/usecases/get_tuition_posts_usecase.dart"
touch "lib/src/features/tuition_posts/domain/usecases/get_my_tuition_posts_usecase.dart"
touch "lib/src/features/tuition_posts/domain/usecases/close_tuition_post_usecase.dart"

# Tuition posts presentation
touch "lib/src/features/tuition_posts/presentation/bloc/tuition_posts_cubit.dart"
touch "lib/src/features/tuition_posts/presentation/pages/tuition_posts_list_page.dart"
touch "lib/src/features/tuition_posts/presentation/pages/tuition_post_detail_page.dart"
touch "lib/src/features/tuition_posts/presentation/pages/create_tuition_post_page.dart"
touch "lib/src/features/tuition_posts/presentation/widgets/tuition_post_card.dart"
touch "lib/src/features/tuition_posts/presentation/widgets/tuition_post_form.dart"

###############################################################################
# Feature: Applications (teacher applying to posts)
###############################################################################

mkdir -p \
  "lib/src/features/applications/data/datasources" \
  "lib/src/features/applications/data/repositories" \
  "lib/src/features/applications/domain/entities" \
  "lib/src/features/applications/domain/repositories" \
  "lib/src/features/applications/domain/usecases" \
  "lib/src/features/applications/presentation/bloc" \
  "lib/src/features/applications/presentation/pages" \
  "lib/src/features/applications/presentation/widgets"

# Applications data
touch "lib/src/features/applications/data/datasources/applications_remote_data_source.dart"
touch "lib/src/features/applications/data/repositories/applications_repository_impl.dart"

# Applications domain
touch "lib/src/features/applications/domain/entities/tuition_application.dart"
touch "lib/src/features/applications/domain/repositories/applications_repository.dart"
touch "lib/src/features/applications/domain/usecases/apply_to_tuition_post_usecase.dart"
touch "lib/src/features/applications/domain/usecases/get_my_applications_usecase.dart"

# Applications presentation
touch "lib/src/features/applications/presentation/bloc/applications_cubit.dart"
touch "lib/src/features/applications/presentation/pages/my_applications_page.dart"
touch "lib/src/features/applications/presentation/widgets/application_card.dart"

###############################################################################
# Feature: Search (teachers & students)
###############################################################################

mkdir -p \
  "lib/src/features/search/data/datasources" \
  "lib/src/features/search/data/repositories" \
  "lib/src/features/search/domain/entities" \
  "lib/src/features/search/domain/repositories" \
  "lib/src/features/search/domain/usecases" \
  "lib/src/features/search/presentation/bloc" \
  "lib/src/features/search/presentation/pages" \
  "lib/src/features/search/presentation/widgets"

# Search data
touch "lib/src/features/search/data/datasources/search_remote_data_source.dart"
touch "lib/src/features/search/data/repositories/search_repository_impl.dart"

# Search domain
touch "lib/src/features/search/domain/entities/search_teacher_result.dart"
touch "lib/src/features/search/domain/entities/search_student_result.dart"
touch "lib/src/features/search/domain/repositories/search_repository.dart"
touch "lib/src/features/search/domain/usecases/search_teachers_usecase.dart"
touch "lib/src/features/search/domain/usecases/search_students_usecase.dart"

# Search presentation
touch "lib/src/features/search/presentation/bloc/search_cubit.dart"
touch "lib/src/features/search/presentation/pages/search_teachers_page.dart"
touch "lib/src/features/search/presentation/pages/search_students_page.dart"
touch "lib/src/features/search/presentation/widgets/search_filters_sheet.dart"
touch "lib/src/features/search/presentation/widgets/search_result_card.dart"

###############################################################################
# Feature: Matches (recommended connections)
###############################################################################

mkdir -p \
  "lib/src/features/matches/data/datasources" \
  "lib/src/features/matches/data/repositories" \
  "lib/src/features/matches/domain/entities" \
  "lib/src/features/matches/domain/repositories" \
  "lib/src/features/matches/domain/usecases" \
  "lib/src/features/matches/presentation/bloc" \
  "lib/src/features/matches/presentation/pages" \
  "lib/src/features/matches/presentation/widgets"

touch "lib/src/features/matches/data/datasources/matches_remote_data_source.dart"
touch "lib/src/features/matches/data/repositories/matches_repository_impl.dart"
touch "lib/src/features/matches/domain/entities/match_item.dart"
touch "lib/src/features/matches/domain/repositories/matches_repository.dart"
touch "lib/src/features/matches/domain/usecases/get_my_matches_usecase.dart"
touch "lib/src/features/matches/presentation/bloc/matches_cubit.dart"
touch "lib/src/features/matches/presentation/pages/matches_page.dart"
touch "lib/src/features/matches/presentation/widgets/match_card.dart"

###############################################################################
# Feature: Demo Sessions
###############################################################################

mkdir -p \
  "lib/src/features/demo_sessions/data/datasources" \
  "lib/src/features/demo_sessions/data/repositories" \
  "lib/src/features/demo_sessions/domain/entities" \
  "lib/src/features/demo_sessions/domain/repositories" \
  "lib/src/features/demo_sessions/domain/usecases" \
  "lib/src/features/demo_sessions/presentation/bloc" \
  "lib/src/features/demo_sessions/presentation/pages" \
  "lib/src/features/demo_sessions/presentation/widgets"

touch "lib/src/features/demo_sessions/data/datasources/demo_sessions_remote_data_source.dart"
touch "lib/src/features/demo_sessions/data/repositories/demo_sessions_repository_impl.dart"
touch "lib/src/features/demo_sessions/domain/entities/demo_session.dart"
touch "lib/src/features/demo_sessions/domain/repositories/demo_sessions_repository.dart"
touch "lib/src/features/demo_sessions/domain/usecases/request_demo_session_usecase.dart"
touch "lib/src/features/demo_sessions/domain/usecases/get_demo_sessions_usecase.dart"
touch "lib/src/features/demo_sessions/domain/usecases/update_demo_session_status_usecase.dart"
touch "lib/src/features/demo_sessions/presentation/bloc/demo_sessions_cubit.dart"
touch "lib/src/features/demo_sessions/presentation/pages/demo_sessions_page.dart"
touch "lib/src/features/demo_sessions/presentation/pages/demo_session_detail_page.dart"
touch "lib/src/features/demo_sessions/presentation/widgets/demo_session_card.dart"

###############################################################################
# Feature: Chat (REST + WebSocket)
###############################################################################

mkdir -p \
  "lib/src/features/chat/data/datasources" \
  "lib/src/features/chat/data/repositories" \
  "lib/src/features/chat/domain/entities" \
  "lib/src/features/chat/domain/repositories" \
  "lib/src/features/chat/domain/usecases" \
  "lib/src/features/chat/presentation/bloc" \
  "lib/src/features/chat/presentation/pages" \
  "lib/src/features/chat/presentation/widgets"

# Chat data
touch "lib/src/features/chat/data/datasources/chat_remote_data_source.dart"
touch "lib/src/features/chat/data/datasources/chat_socket_data_source.dart"
touch "lib/src/features/chat/data/repositories/chat_repository_impl.dart"

# Chat domain
touch "lib/src/features/chat/domain/entities/chat_room.dart"
touch "lib/src/features/chat/domain/entities/chat_message.dart"
touch "lib/src/features/chat/domain/repositories/chat_repository.dart"
touch "lib/src/features/chat/domain/usecases/get_my_chat_rooms_usecase.dart"
touch "lib/src/features/chat/domain/usecases/get_chat_messages_usecase.dart"
touch "lib/src/features/chat/domain/usecases/send_chat_message_usecase.dart"
touch "lib/src/features/chat/domain/usecases/mark_chat_read_usecase.dart"

# Chat presentation
touch "lib/src/features/chat/presentation/bloc/chat_rooms_cubit.dart"
touch "lib/src/features/chat/presentation/bloc/chat_messages_cubit.dart"
touch "lib/src/features/chat/presentation/pages/chat_rooms_page.dart"
touch "lib/src/features/chat/presentation/pages/chat_page.dart"
touch "lib/src/features/chat/presentation/widgets/chat_message_bubble.dart"
touch "lib/src/features/chat/presentation/widgets/chat_input_bar.dart"

###############################################################################
# Feature: Notifications
###############################################################################

mkdir -p \
  "lib/src/features/notifications/data/datasources" \
  "lib/src/features/notifications/data/repositories" \
  "lib/src/features/notifications/domain/entities" \
  "lib/src/features/notifications/domain/repositories" \
  "lib/src/features/notifications/domain/usecases" \
  "lib/src/features/notifications/presentation/bloc" \
  "lib/src/features/notifications/presentation/pages" \
  "lib/src/features/notifications/presentation/widgets"

touch "lib/src/features/notifications/data/datasources/notifications_remote_data_source.dart"
touch "lib/src/features/notifications/data/repositories/notifications_repository_impl.dart"
touch "lib/src/features/notifications/domain/entities/app_notification.dart"
touch "lib/src/features/notifications/domain/repositories/notifications_repository.dart"
touch "lib/src/features/notifications/domain/usecases/get_my_notifications_usecase.dart"
touch "lib/src/features/notifications/domain/usecases/mark_notification_read_usecase.dart"
touch "lib/src/features/notifications/presentation/bloc/notifications_cubit.dart"
touch "lib/src/features/notifications/presentation/pages/notifications_page.dart"
touch "lib/src/features/notifications/presentation/widgets/notification_tile.dart"

###############################################################################
# Feature: Reviews / Ratings
###############################################################################

mkdir -p \
  "lib/src/features/reviews/data/datasources" \
  "lib/src/features/reviews/data/repositories" \
  "lib/src/features/reviews/domain/entities" \
  "lib/src/features/reviews/domain/repositories" \
  "lib/src/features/reviews/domain/usecases" \
  "lib/src/features/reviews/presentation/bloc" \
  "lib/src/features/reviews/presentation/pages" \
  "lib/src/features/reviews/presentation/widgets"

touch "lib/src/features/reviews/data/datasources/reviews_remote_data_source.dart"
touch "lib/src/features/reviews/data/repositories/reviews_repository_impl.dart"
touch "lib/src/features/reviews/domain/entities/teacher_review.dart"
touch "lib/src/features/reviews/domain/repositories/reviews_repository.dart"
touch "lib/src/features/reviews/domain/usecases/get_teacher_reviews_usecase.dart"
touch "lib/src/features/reviews/domain/usecases/add_teacher_review_usecase.dart"
touch "lib/src/features/reviews/presentation/bloc/reviews_cubit.dart"
touch "lib/src/features/reviews/presentation/pages/teacher_reviews_page.dart"
touch "lib/src/features/reviews/presentation/pages/add_review_page.dart"
touch "lib/src/features/reviews/presentation/widgets/review_card.dart"
touch "lib/src/features/reviews/presentation/widgets/review_form.dart"

###############################################################################
# Feature: Admin (approvals, stats)
###############################################################################

mkdir -p \
  "lib/src/features/admin/data/datasources" \
  "lib/src/features/admin/data/repositories" \
  "lib/src/features/admin/domain/entities" \
  "lib/src/features/admin/domain/repositories" \
  "lib/src/features/admin/domain/usecases" \
  "lib/src/features/admin/presentation/bloc" \
  "lib/src/features/admin/presentation/pages" \
  "lib/src/features/admin/presentation/widgets"

touch "lib/src/features/admin/data/datasources/admin_remote_data_source.dart"
touch "lib/src/features/admin/data/repositories/admin_repository_impl.dart"
touch "lib/src/features/admin/domain/entities/admin_stats.dart"
touch "lib/src/features/admin/domain/entities/admin_user_item.dart"
touch "lib/src/features/admin/domain/entities/admin_demo_session_item.dart"
touch "lib/src/features/admin/domain/repositories/admin_repository.dart"
touch "lib/src/features/admin/domain/usecases/get_admin_stats_usecase.dart"
touch "lib/src/features/admin/domain/usecases/get_users_for_admin_usecase.dart"
touch "lib/src/features/admin/domain/usecases/toggle_user_suspension_usecase.dart"
touch "lib/src/features/admin/domain/usecases/approve_teacher_profile_usecase.dart"
touch "lib/src/features/admin/domain/usecases/approve_tuition_post_usecase.dart"
touch "lib/src/features/admin/domain/usecases/approve_application_usecase.dart"
touch "lib/src/features/admin/domain/usecases/get_demo_sessions_admin_usecase.dart"
touch "lib/src/features/admin/domain/usecases/update_demo_session_status_admin_usecase.dart"
touch "lib/src/features/admin/presentation/bloc/admin_dashboard_cubit.dart"
touch "lib/src/features/admin/presentation/pages/admin_dashboard_page.dart"
touch "lib/src/features/admin/presentation/pages/admin_users_page.dart"
touch "lib/src/features/admin/presentation/pages/admin_demo_sessions_page.dart"
touch "lib/src/features/admin/presentation/widgets/admin_stats_header.dart"
touch "lib/src/features/admin/presentation/widgets/admin_user_list_item.dart"
touch "lib/src/features/admin/presentation/widgets/admin_demo_session_card.dart"

###############################################################################
# Feature: Settings & Account
###############################################################################

mkdir -p \
  "lib/src/features/settings/presentation/pages" \
  "lib/src/features/settings/presentation/widgets" \
  "lib/src/features/settings/presentation/bloc"

touch "lib/src/features/settings/presentation/pages/settings_page.dart"
touch "lib/src/features/settings/presentation/pages/account_settings_page.dart"
touch "lib/src/features/settings/presentation/bloc/settings_cubit.dart"
touch "lib/src/features/settings/presentation/widgets/settings_section.dart"
touch "lib/src/features/settings/presentation/widgets/settings_tile.dart"

###############################################################################
# Shared / generic UI
###############################################################################

mkdir -p \
  "lib/src/shared/dialogs" \
  "lib/src/shared/bottom_sheets" \
  "lib/src/shared/forms"

touch "lib/src/shared/dialogs/confirm_dialog.dart"
touch "lib/src/shared/dialogs/info_dialog.dart"
touch "lib/src/shared/bottom_sheets/app_bottom_sheet.dart"
touch "lib/src/shared/forms/form_section.dart"

echo "✅ Folder structure and empty Dart files created successfully."
