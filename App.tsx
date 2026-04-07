import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { Alert, Pressable, SafeAreaView, Text, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { supabase } from './src/supabase';
import { styles } from './src/components/AppStyles';
import { Logo } from './src/components/Logo';
import { TabBar } from './src/components/TabBar';
import { LoginScreen } from './src/screens/LoginScreen';
import { HomeScreen } from './src/screens/HomeScreen';
import { ScheduleScreen } from './src/screens/ScheduleScreen';
import { MembershipScreen } from './src/screens/MembershipScreen';
import { PaymentsScreen } from './src/screens/PaymentsScreen';
import { FormsScreen } from './src/screens/FormsScreen';
import { UpdatesScreen } from './src/screens/UpdatesScreen';
import { LinkStatus, MemberLinkRow, TabKey, AppRole } from './src/types';
import { fetchMemberLink, relinkMember } from './src/services/member';
import { submitMemberRequest } from './src/services/requests';
import { getAppRole } from './src/constants/roles';

const ROLE_OPTIONS: AppRole[] = ['admin', 'instructor', 'member'];

function AppShell({ userEmail, onLogout }: { userEmail: string; onLogout: () => void }) {
  const actualRole: AppRole = getAppRole(userEmail);
  const canSwitchViews = actualRole === 'admin' || userEmail.trim().toLowerCase() === 'ryangruhn@gmail.com';
  const [roleMenuOpen, setRoleMenuOpen] = useState(false);
  const [viewAsRole, setViewAsRole] = useState<AppRole>(actualRole);
  const role: AppRole = canSwitchViews ? viewAsRole : actualRole;
  const [tab, setTab] = useState<TabKey>('Home');
  const [updatesView, setUpdatesView] = useState<'updates' | 'admin' | 'messages' | 'events' | 'notifications' | 'university' | 'employee' | 'checkin'>(actualRole === 'admin' ? 'admin' : 'checkin');
  const [linkStatus, setLinkStatus] = useState<LinkStatus>('idle');
  const [memberLink, setMemberLink] = useState<MemberLinkRow | null>(null);

  useEffect(() => {
    setViewAsRole(actualRole);
  }, [actualRole]);

  useEffect(() => {
    setUpdatesView(role === 'admin' ? 'admin' : 'checkin');
  }, [role]);

  const availableTabs = useMemo<TabKey[]>(() => {
    if (role === 'member') return ['Home', 'Schedule', 'Membership', 'Payments', 'Forms', 'Updates'];
    if (role === 'instructor') return ['Home', 'Schedule', 'Membership', 'Forms', 'Updates'];
    return ['Home', 'Schedule', 'Membership', 'Payments', 'Forms', 'Updates'];
  }, [role]);

  useEffect(() => {
    if (!availableTabs.includes(tab)) setTab(availableTabs[0]);
  }, [availableTabs, tab]);

  const refreshData = useCallback(async () => {
    try {
      const { row, status } = await fetchMemberLink(userEmail);
      setMemberLink(row);
      setLinkStatus(status);
    } catch {
      setLinkStatus('error');
    }
  }, [userEmail]);

  const relink = useCallback(async () => {
    try {
      setLinkStatus('linking');
      const status = await relinkMember();
      setLinkStatus(status);
      await refreshData();
    } catch {
      setLinkStatus('error');
      Alert.alert('Link issue', 'The iGo360 link did not complete. We can keep building the rest of the app while this API behavior is finalized.');
    }
  }, [refreshData]);

  useEffect(() => {
    refreshData();
  }, [refreshData]);

  const handleSubmitRequest = useCallback(async (type: 'hold' | 'cancel', reason: string, ack: boolean) => {
    if (!ack) {
      return Alert.alert('Required', 'Please confirm the rules first.');
    }

    try {
      await submitMemberRequest(type, reason, ack);
      Alert.alert('Submitted', `Your ${type} request was submitted.`);
    } catch (e: any) {
      Alert.alert('Unable to submit', e?.message ?? 'Please try again.');
    }
  }, []);

  const content = useMemo(() => {
    switch (tab) {
      case 'Home':
        return <HomeScreen setTab={setTab} setUpdatesView={setUpdatesView} linkStatus={linkStatus} relink={relink} memberLink={memberLink} userEmail={userEmail} role={role} />;
      case 'Schedule':
        return <ScheduleScreen userEmail={userEmail} />;
      case 'Membership':
        return <MembershipScreen row={memberLink} userEmail={userEmail} role={role} />;
      case 'Payments':
        return <PaymentsScreen row={memberLink} userEmail={userEmail} role={role} />;
      case 'Forms':
        return <FormsScreen submitRequest={handleSubmitRequest} userEmail={userEmail} role={role} setTab={setTab} setUpdatesView={setUpdatesView} />;
      case 'Updates':
        return <UpdatesScreen userEmail={userEmail} role={role} view={updatesView} setView={setUpdatesView} />;
      default:
        return null;
    }
  }, [tab, linkStatus, relink, memberLink, userEmail, handleSubmitRequest, role]);

  const headerTabLabel = tab === 'Updates' ? (role === 'admin' ? 'Admin' : 'Check-in') : tab;

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="dark" translucent={false} />
      <View style={styles.header}>
        <View style={styles.headerInner}>
          <Logo size={42} />
          <View style={{ flex: 1 }}>
            <Text style={styles.headerTitle}>CPAMMA</Text>
            <Text style={styles.headerSubtitle}>{headerTabLabel}</Text>
          </View>
          <Pressable onPress={onLogout}>
            <Text style={styles.logoutText}>Log out</Text>
          </Pressable>
        </View>
        {canSwitchViews ? (
          <View style={styles.viewAsWrap}>
            <Text style={styles.viewAsLabel}>Role Picker</Text>
            <Pressable style={styles.viewAsButton} onPress={() => setRoleMenuOpen((value) => !value)}>
              <Text style={styles.viewAsButtonText}>{role.charAt(0).toUpperCase() + role.slice(1)}</Text>
              <Text style={styles.viewAsChevron}>{roleMenuOpen ? '▲' : '▼'}</Text>
            </Pressable>
            {roleMenuOpen ? (
              <View style={styles.viewAsMenu}>
                {ROLE_OPTIONS.map((option) => {
                  const selected = option === role;
                  return (
                    <Pressable
                      key={option}
                      style={[styles.viewAsMenuItem, selected && styles.viewAsMenuItemActive]}
                      onPress={() => {
                        setViewAsRole(option);
                        setRoleMenuOpen(false);
                      }}
                    >
                      <Text style={[styles.viewAsMenuText, selected && styles.viewAsMenuTextActive]}>
                        {option.charAt(0).toUpperCase() + option.slice(1)}
                      </Text>
                    </Pressable>
                  );
                })}
              </View>
            ) : null}
          </View>
        ) : null}
      </View>
      <View style={styles.body}>{content}</View>
      <TabBar activeTab={tab} setTab={setTab} tabs={availableTabs} role={role} />
    </SafeAreaView>
  );
}

export default function App() {
  const [ready, setReady] = useState(false);
  const [authed, setAuthed] = useState(false);
  const [userEmail, setUserEmail] = useState('');

  useEffect(() => {
    let mounted = true;

    supabase.auth.getSession().then(({ data }) => {
      if (!mounted) return;
      setUserEmail(data.session?.user?.email ?? '');
      setAuthed(!!data.session);
      setReady(true);
    });

    const { data: sub } = supabase.auth.onAuthStateChange((_event, session) => {
      setUserEmail(session?.user?.email ?? '');
      setAuthed(!!session);
      setReady(true);
    });

    return () => {
      mounted = false;
      sub.subscription.unsubscribe();
    };
  }, []);

  const logout = async () => {
    await supabase.auth.signOut();
  };

  if (!ready) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.centered}>
          <Logo size={70} />
          <Text style={styles.heroTitle}>CPAMMA</Text>
          <Text style={styles.infoText}>Loading...</Text>
        </View>
      </SafeAreaView>
    );
  }

  return authed ? <AppShell userEmail={userEmail} onLogout={logout} /> : <LoginScreen onAuthed={() => setAuthed(true)} />;
}
