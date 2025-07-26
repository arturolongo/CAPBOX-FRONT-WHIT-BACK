import 'package:capbox/features/admin/presentation/pages/admin_attendance_page.dart';
import 'package:capbox/features/admin/presentation/pages/admin_home_page.dart';
import 'package:capbox/features/admin/presentation/pages/admin_manage_students_page.dart';
import 'package:capbox/features/admin/presentation/pages/admin_student_profile_page.dart';
import 'package:capbox/features/admin/presentation/pages/admin_gym_key_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_ficha_tecnica_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_history_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_metrics_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_profile_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_summary_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_technique_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_timer_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_timer_summary_page.dart';
import 'package:capbox/features/coach/domain/entities/student_model.dart';
import 'package:capbox/features/coach/presentation/pages/coach_assign_goals_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_assign_routine_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_create_routine_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_edit_student_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_register_physical_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_register_tutor_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_capture_data_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_pending_athletes_page.dart';
import 'package:capbox/features/admin/data/dtos/gym_member_dto.dart';
import 'package:capbox/features/coach/presentation/pages/coach_request_capture_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_select_student_for_test_page.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_ai_tools_page.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_fight_history_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_home_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_manage_routine_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_manage_routines_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_manage_students_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_metrics_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_performance_test2_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_performance_test_3_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_performance_test_4_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_performance_test_5_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_performance_test_6_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_performance_test_7_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_performance_test_8_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_routines_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_select_student_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_student_profile_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_student_test_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_student_test_preview_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_technical_profile_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_update_goals_page.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_ranking_page.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_ranking_sparrings_page.dart';
import 'package:capbox/features/coach/presentation/widgets/coach_register_fight_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:capbox/features/auth/presentation/pages/login_page.dart';
import 'package:capbox/features/auth/presentation/pages/register_page.dart';
import 'package:capbox/features/auth/presentation/pages/confirmation_code_page.dart';
import 'package:capbox/features/auth/presentation/pages/resend_code_page.dart';
import 'package:capbox/features/auth/presentation/pages/gym_key_required_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_gym_key_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_home_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_events_page.dart';
import 'package:capbox/features/boxer/presentation/pages/boxer_invitation_detail_page.dart';
import 'package:capbox/features/coach/presentation/pages/coach_attendance_page.dart';

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(
      path: '/confirm-code',
      builder: (context, state) {
        final email = state.extra as String;
        return ConfirmationCodePage(email: email);
      },
    ),
    GoRoute(path: '/resend-code', builder: (_, __) => const ResendCodePage()),
    GoRoute(
      path: '/gym-key-required',
      builder: (context, state) {
        final userRole = state.extra as String;
        return GymKeyRequiredPage(userRole: userRole);
      },
    ),
    GoRoute(path: '/boxer-home', builder: (_, __) => const BoxerHomePage()),
    GoRoute(path: '/boxer-events', builder: (_, __) => const BoxerEventsPage()),
    GoRoute(
      path: '/boxer-events-detail',
      builder: (_, __) => const BoxerEventsPage(),
    ),
    GoRoute(
      path: '/invitation-detail',
      builder: (_, __) => const BoxerInvitationDetailPage(),
    ),
    GoRoute(path: '/perfil', builder: (_, __) => const BoxerProfilePage()),
    GoRoute(path: '/historial', builder: (_, __) => const BoxerHistoryPage()),
    GoRoute(
      path: '/ficha-tecnica',
      builder: (_, __) => const BoxerFichaTecnicaPage(),
    ),
    GoRoute(path: '/metrics', builder: (_, __) => const BoxerMetricsPage()),
    GoRoute(path: '/timer', builder: (_, __) => const BoxerTimerPage()),
    GoRoute(
      path: '/timer-summary',
      builder: (_, __) => const BoxerTimerSummaryPage(),
    ),
    GoRoute(
      path: '/technique',
      pageBuilder:
          (context, state) => const MaterialPage(child: BoxerTechniquePage()),
    ),
    GoRoute(
      path: '/summary',
      builder: (context, state) => const BoxerSummaryPage(),
    ),

    //entrenador
    GoRoute(
      path: '/coach-home',
      builder: (context, state) => const CoachHomePage(),
    ),
    GoRoute(
      path: '/coach-attendance',
      builder: (_, __) => const CoachAttendancePage(),
    ),
    GoRoute(
      path: '/coach-routines',
      builder: (context, state) => const CoachRoutinesPage(),
    ),
    GoRoute(
      path: '/assign-routine/:nivel',
      builder: (context, state) {
        final nivel = state.pathParameters['nivel']!;
        return CoachAssignRoutinePage(nivel: nivel);
      },
    ),
    GoRoute(
      path: '/coach/manage-routines',
      builder: (context, state) => const CoachManageRoutinesPage(),
    ),
    GoRoute(
      path: '/coach/manage/:nivel',
      builder: (context, state) {
        final nivel = state.pathParameters['nivel']!;
        return CoachManageRoutinePage(nivel: nivel);
      },
    ),
    GoRoute(
      path: '/coach/create-routine',
      builder: (context, state) => const CoachCreateRoutinePage(),
    ),
    GoRoute(
      path: '/coach/assign-goals',
      builder: (context, state) => const CoachAssignGoalsPage(),
    ),
    GoRoute(
      path: '/coach/gym-key',
      builder: (context, state) => const CoachGymKeyPage(),
    ),
    GoRoute(
      path: '/coach/capture-data',
      builder: (context, state) {
        final athlete = state.extra as GymMemberDto;
        return CoachCaptureDataPage(athlete: athlete);
      },
    ),
    GoRoute(
      path: '/coach/pending-athletes',
      builder: (context, state) => const CoachPendingAthletesPage(),
    ),
    GoRoute(
      path: '/coach/select-student',
      builder: (context, state) => CoachSelectStudentPage(),
    ),
    GoRoute(
      path: '/coach-manage-students',
      builder: (context, state) => CoachManageStudentsPage(),
    ),
    GoRoute(
      path: '/coach-ficha-tecnica',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CoachTechnicalProfilePage(data: extra);
      },
    ),
    GoRoute(
      path: '/coach-update-goals',
      builder: (context, state) => const CoachUpdateGoalsPage(),
    ),
    GoRoute(
      path: '/coach/student-profile',
      builder:
          (context, state) => const CoachStudentProfilePage(studentName: ''),
    ),
    GoRoute(
      path: '/coach/student-test-preview',
      name: 'studentTestPreview',
      builder: (context, state) => const CoachStudentTestPreviewPage(),
    ),
    GoRoute(
      path: '/coach/student-test',
      name: 'student-test',
      builder: (context, state) => const CoachStudentTestPage(),
    ),
    GoRoute(
      path: '/coach-performance-test-2',
      builder: (context, state) => const CoachPerformanceTest2Page(),
    ),
    GoRoute(
      path: '/coach-performance-test-3',
      builder: (context, state) => const CoachPerformanceTest3Page(),
    ),
    GoRoute(
      path: '/coach-performance-test-4',
      builder: (context, state) => const CoachPerformanceTest4Page(),
    ),
    GoRoute(
      path: '/coach-performance-test-5',
      builder: (context, state) => const CoachPerformanceTest5Page(),
    ),
    GoRoute(
      path: '/coach-performance-test-6',
      builder: (context, state) => const CoachPerformanceTest6Page(),
    ),
    GoRoute(
      path: '/coach-performance-test-7',
      builder: (context, state) => const CoachPerformanceTest7Page(),
    ),
    GoRoute(
      path: '/coach-performance-test-8',
      builder: (context, state) => const CoachPerformanceTest8Page(),
    ),
    GoRoute(
      path: '/coach-metrics',
      builder: (context, state) => const CoachMetricsPage(studentName: ''),
    ),
    GoRoute(
      path: '/coach/metrics',
      builder: (context, state) {
        final studentName = state.extra as String;
        return CoachMetricsPage(studentName: studentName);
      },
    ),
    GoRoute(
      path: '/coach/fights',
      builder: (context, state) {
        final studentName = state.extra as String;
        return CoachFightHistoryPage(studentName: studentName);
      },
    ),
    GoRoute(
      path: '/coach-fight-register',
      name: 'coach-fight-register',
      builder: (context, state) => const CoachRegisterFightPage(),
    ),
    GoRoute(
      path: '/coach/edit-student',
      builder: (context, state) => const CoachEditStudentPage(),
    ),
    GoRoute(
      path: '/coach/register-tutor',
      name: 'register-tutor',
      builder: (context, state) => const CoachRegisterTutorPage(),
    ),
    GoRoute(
      path: '/coach/register-physical',
      builder: (context, state) => const CoachRegisterPhysicalPage(),
    ),
    GoRoute(
      path: '/coach-request-capture',
      builder: (context, state) => const CoachRequestCapturePage(),
    ),
    GoRoute(
      path: '/coach-select-student-for-test',
      name: 'coach-select-student-for-test',
      builder: (context, state) => const CoachSelectStudentForTestPage(),
    ),
    GoRoute(
      path: '/coach-ai-tools',
      builder: (context, state) => const CoachAIToolsPage(),
    ),
    GoRoute(
      path: '/coach-ranking',
      builder: (context, state) => const CoachRankingPage(),
    ),
    GoRoute(
      path: '/ranking-sparrings',
      builder: (context, state) => const CoachRankingSparringsPage(),
    ),

    //administración
    GoRoute(
      path: '/admin-home',
      builder: (context, state) => const AdminHomePage(),
    ),
    GoRoute(
      path: '/admin-attendance',
      builder: (context, state) => const AdminAttendancePage(),
    ),
    GoRoute(
      path: '/admin-manage-students',
      builder: (context, state) => const AdminManageStudentsPage(),
    ),
    GoRoute(
      path: '/admin/gym-key',
      builder: (context, state) => const AdminGymKeyPage(),
    ),
    GoRoute(
      path: '/admin/alumno/perfil',
      builder: (context, state) {
        final student = state.extra as Student;
        return AdminStudentProfilePage(student: student);
      },
    ),
  ],
);
