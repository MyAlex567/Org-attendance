import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';
import '../atoms/app_text.dart';
import '../../providers/auth_provider.dart';
import '../../models/membership.dart';
import '../../providers/org_provider.dart';
import '../atoms/app_loader.dart';
import '../molecules/org_card.dart';
import '../molecules/status_message.dart';
import '../organisms/org_form.dart';
import '../organisms/join_org_form.dart';
import 'org_page.dart';
import 'invitations_page.dart';
import '../../models/invite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream<List<Membership>>? _myOrgs;
  Stream<List<Invite>>? _invites;

  Future<void> _addOrgDialog() async {
    await showDialog(
      context: context, 
      builder: (dialogContext){
        final isLoading = dialogContext.watch<OrgProvider>().isLoading;

        return OrgForm(
          onSubmit: (name) async{
            final user = context.read<AuthProvider>().user;
            final error = await context.read<OrgProvider>().createOrg(name, user);

            if(!mounted) return;

            if(error != null){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error))
              );
              return;
            }

            if(!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
          }, 
          isLoading: isLoading
        );
      }
    );
  }

  Future<void> _joinOrgDialog() async {
    await showDialog(
      context: context, 
      builder: (dialogContext){
        final isLoading = dialogContext.watch<OrgProvider>().isLoading;

        return JoinOrgForm(
          onSubmit: (code) async {
            final user = context.read<AuthProvider>().user;
            final error = await context.read<OrgProvider>().joinOrg(code, user);

            if(!mounted) return;

            if(error != null){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error))
              );
              return;
            }

            if(!dialogContext.mounted) return;
            Navigator.pop(dialogContext);

          }, 
          isLoading: isLoading
        );
      } 
    );
  }

  @override
  void initState(){
    super.initState();
    final auth = context.read<AuthProvider>();
    if(auth.user == null) auth.loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = user == null ? '' : user.fullName.split(' ').first;

    if(user != null){
      _myOrgs ??= context.read<OrgProvider>().myOrgs(user.uid);
      _invites ??= context.read<OrgProvider>().watchInvites(user.uid);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'My Orgs',
              variant: AppTextVariant.title,
              color: AppColors.white,
            ),
            AppText(
              text: "Hi, $firstName",
              variant: AppTextVariant.caption,
              color: AppColors.white,
            ),
          ],
        ),
        actions: [
          // Invitations, with a badge showing how many are waiting.
          StreamBuilder<List<Invite>>(
            stream: _invites,
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;

              return IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InvitationsPage()),
                ),
                icon: Badge(
                  // Hide the red dot when there's nothing waiting.
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.mail_outline, color: AppColors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Joining button
          AppButton(
            label: 'Add organization', 
            onPressed: _addOrgDialog
          ),

          const SizedBox(height: 12),

          AppButton(
            label: 'Join organization', 
            onPressed: _joinOrgDialog
          ),

          const SizedBox(height: 24),
          const AppText(text: 'My organizations', variant: AppTextVariant.section, size: 20,),
          const SizedBox(height: 8),

          StreamBuilder<List<Membership>>(
            stream: _myOrgs,
            builder: (context, snapshot){
              if(snapshot.hasError){
                debugPrint('Orgs error: ${snapshot.error}'); 
                return const StatusMessage(
                  icon: Icons.error_outline,
                  message: 'Something went wrong',
                );
              }

              if(!snapshot.hasData){
                return const AppLoader();
              }

              final orgs = snapshot.data!;
              if(orgs.isEmpty){
                return const StatusMessage(
                  icon: Icons.groups_outlined, 
                  message: "You have not joined any organization yet"
                );
              }

              return Column(
                children: [
                  for(final org in orgs)
                    OrgCard(
                      orgName: org.orgName, 
                      role: org.role, 
                      onTap: () => Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => OrgPage(
                            orgId: org.orgId, 
                            orgName: org.orgName, 
                            role: org.role
                          ),
                        ),
                      ),
                    ),
                ],
              );  
            },
          ),

        ],
      ),
    );
  }
}

