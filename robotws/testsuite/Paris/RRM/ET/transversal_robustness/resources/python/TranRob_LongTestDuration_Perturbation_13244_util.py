import alarms_handler as Almh
import emss_handler as Emsh
import os
import time


def _check_bts_oam_connection_status(max_attempts=5, retry_interval=30):
    """
    Vérifie que le BTS OAM est connecté et découvert avant configuration.

    Args:
        max_attempts: Nombre maximal de tentatives (défaut: 5)
        retry_interval: Délai en secondes entre les tentatives (défaut: 30s)

    Returns:
        bool: True si BTS OAM connecté et découvert

    Raises:
        RuntimeError: Si BTS OAM non connecté après max_attempts
    """
    print(f"\n{'='*70}")
    print("VÉRIFICATION CONNEXION BTS OAM")
    print(f"{'='*70}")

    for attempt in range(1, max_attempts + 1):
        try:
            print(f"\n[Tentative {attempt}/{max_attempts}] Vérification du statut BTS...")

            # Exécuter la commande bts_connection_status via EMSsim
            result = Emsh.emss.run_emssim_command('bts_connection_status')

            if result:
                tcp_connected = result.get('tcp_connection_status', 0)
                oam_connected = result.get('connection_status', 0)
                discovered = result.get('discover_status', 0)

                print(f"  • TCP Connected: {tcp_connected}")
                print(f"  • OAM Connected: {oam_connected}")
                print(f"  • Discovered: {discovered}")

                # Vérifier que tout est OK
                if tcp_connected and oam_connected and discovered:
                    print(f"\n✓ BTS OAM connecté et découvert (tentative {attempt}/{max_attempts})")
                    print(f"{'='*70}\n")
                    return True
                else:
                    status_msgs = []
                    if not tcp_connected:
                        status_msgs.append("TCP non connecté")
                    if not oam_connected:
                        status_msgs.append("OAM non connecté")
                    if not discovered:
                        status_msgs.append("BTS non découvert")

                    print(f"  ⚠ BTS pas prêt: {', '.join(status_msgs)}")
            else:
                print("  ⚠ Impossible d'obtenir le statut BTS (commande retourne None)")

        except Exception as e:
            print(f"  ✗ Erreur lors de la vérification: {e}")

        # Attendre avant la prochaine tentative (sauf pour la dernière)
        if attempt < max_attempts:
            print(f"  → Nouvelle tentative dans {retry_interval}s...")
            time.sleep(retry_interval)

    # Si on arrive ici, échec après toutes les tentatives
    error_msg = (
        f"\n{'='*70}\n"
        f"✗ ÉCHEC: BTS OAM non connecté après {max_attempts} tentatives\n"
        f"  ({max_attempts * retry_interval}s d'attente totale)\n"
        f"\n"
        f"ACTIONS RECOMMANDÉES:\n"
        f"  1. Vérifier que le BTS est démarré et opérationnel\n"
        f"  2. Vérifier la connexion réseau entre BTS et EMSsim (10.0.1.1:4001)\n"
        f"  3. Consulter les logs BTS et EMSsim\n"
        f"  4. Relancer EMSsim si nécessaire\n"
        f"{'='*70}\n"
    )
    print(error_msg)
    raise RuntimeError(
        f"BTS OAM non connecté après {max_attempts} tentatives. "
        f"Impossible de modifier la configuration."
    )


def online_activate_feature_cb013244_a_b_c_python():
    """
    Active les features CB013244 A/B/C avec vérification préalable de l'état BTS OAM.
    """
    print("\n→ Activation des features CB013244 A/B/C...")

    # Vérifier la connexion BTS OAM avant de configurer
    _check_bts_oam_connection_status(max_attempts=5, retry_interval=30)

    # Si on arrive ici, le BTS est connecté, on peut configurer
    print("→ Application de la configuration...")
    Emsh.emss.configure("[{'MOC': 'NRCELL', 'ID': '3', 'actCDrx': 'false'}, "
                        "{'MOC': 'NRCELL', 'ID': '3', 'actPreventBWPSwitchInBadConditions': 'true'}]")

    print("✓ Features CB013244 A/B/C activées avec succès\n")


def online_deactivate_feature_cb013244_a_b_c_python():
    """
    Désactive les features CB013244 A/B/C avec vérification préalable de l'état BTS OAM.
    """
    print("\n→ Désactivation des features CB013244 A/B/C...")

    # Vérifier la connexion BTS OAM avant de configurer
    _check_bts_oam_connection_status(max_attempts=5, retry_interval=30)

    # Si on arrive ici, le BTS est connecté, on peut configurer
    print("→ Application de la configuration...")
    Emsh.emss.configure("[{'MOC': 'NRCELL', 'ID': '3', 'actCDrx': 'false'}, "
                        "{'MOC': 'NRCELL', 'ID': '3', 'actPreventBWPSwitchInBadConditions': 'false'}]")

    print("✓ Features CB013244 A/B/C désactivées avec succès\n")
