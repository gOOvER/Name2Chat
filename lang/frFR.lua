local L = LibStub("AceLocale-3.0"):NewLocale("Name2Chat", "frFR")
if not L then return end

L["channel"] = "Canal"
L["channel_desc"] = "Ajouter le nom aux messages de chat dans ce canal personnalisé."
L["config"] = "Configuration"
L["config_desc"] = "Ouvrir le dialogue de configuration."
L["debug"] = "Débogage"
L["debug_desc"] = "Activer les messages de débogage. Vous ne voudrez probablement pas activer ceci."
L["enable"] = "Activer"
L["enable_desc"] = "Activer l'ajout de votre nom aux messages de chat."
L["guild"] = "Guilde"
L["guild_desc"] = "Ajouter le nom aux messages du chat de guilde (/g et /o)."
L["hideOnMatchingCharName"] = "Masquer le nom s'il correspond au nom de votre personnage"
L["hideOnMatchingCharName_desc"] = "Si le nom spécifié correspond au nom de votre personnage actuel, il ne sera pas ajouté à nouveau."
L["instance_chat"] = "Instance"
L["instance_chat_desc"] = "Ajouter le nom aux messages de chat d'instance, ex. : LFR et champs de bataille (/i)."
L["Loaded"] = "Chargé."
L["name"] = "Nom"
L["name_desc"] = "Le nom qui doit être affiché dans vos messages de chat."
L["party"] = "Groupe"
L["party_desc"] = "Ajouter le nom aux messages du chat de groupe (/p)."
L["raid"] = "Raid"
L["raid_desc"] = "Ajouter le nom aux messages du chat de raid (/raid)."
L["ignoreExclamationMark"] = "Ne pas ajouter le nom aux messages commençant par !"
L["ignoreExclamationMark_desc"] = "Si un message commence par un point d'exclamation (!), le nom ne sera pas ajouté. Utile pour les commandes d'addon comme !keys."

-- Messages de statut / avertissements
L["hook_active_eventregistry"] = "Hook actif (ChatFrame.OnEditBoxPreSendText)"
L["hook_active_mixin"] = "Hook actif (ChatFrameEditBoxMixin.SendText fallback)"
L["hook_error_no_entry"] = "ERREUR : Aucun point d'entrée de hook trouvé."
L["hook_error_modify"] = "Erreur lors de la modification du message de chat : "
L["warn_restrictions_enforced"] = "Avertissement : Les restrictions de chat des addons sont désormais appliquées. Les fonctionnalités de Name2Chat peuvent être limitées."
L["warn_restrictions_lifted"] = "Les restrictions de chat des addons ont été levées."

-- Messages de débogage
L["debug_hook_fired"] = "ModifyChatMessage : hook déclenché"
L["debug_disabled"] = "ModifyChatMessage : addon DÉSACTIVÉ, ignoré"
L["debug_name_empty"] = "ModifyChatMessage : nom VIDE, ignoré"
L["debug_name_matches_char"] = "ModifyChatMessage : le nom correspond au nom du personnage et hideOnMatchingCharName est activé, ignoré"
L["debug_msg_empty"] = "ModifyChatMessage : message vide, ignoré"
L["debug_chattype"] = "ModifyChatMessage : chatType=%s, nom=%s"
L["debug_should_add"] = "ModifyChatMessage : shouldAddName=%s"
L["debug_skip_exclamation"] = "ModifyChatMessage : ignoré, le message commence par ! (ignoreExclamationMark actif)"
L["debug_modified"] = "ModifyChatMessage : OK -> %s"
L["debug_chattype_not_active"] = "ModifyChatMessage : chatType '%s' absent de la liste des canaux actifs. guilde=%s groupe=%s raid=%s instance=%s"
L["debug_combat_lockdown"] = "ModifyChatMessage : verrouillage de combat actif, modification du texte ignorée (évite le taint)"


