local L = LibStub("AceLocale-3.0"):NewLocale("Name2Chat", "itIT")
if not L then return end

L["channel"] = "Canale"
L["channel_desc"] = "Aggiunge il nome ai messaggi nella chat di questo canale personalizzato."
L["config"] = "Configurazione"
L["config_desc"] = "Apre la finestra di configurazione."
L["debug"] = "Debug"
L["debug_desc"] = "Abilita i messaggi di debug. Di solito non è necessario attivare questa opzione."
L["enable"] = "Abilita"
L["enable_desc"] = "Abilita l'aggiunta del tuo nome ai messaggi della chat."
L["guild"] = "Gilda"
L["guild_desc"] = "Aggiunge il nome ai messaggi della chat di gilda (/g e /o)."
L["hideOnMatchingCharName"] = "Nascondi il nome se coincide con quello del personaggio"
L["hideOnMatchingCharName_desc"] = "Se il nome specificato corrisponde al nome del personaggio attuale, non verrà aggiunto di nuovo."
L["instance_chat"] = "Istanza"
L["instance_chat_desc"] = "Aggiunge il nome ai messaggi della chat di istanza, es. LFR e campi di battaglia (/i)."
L["Loaded"] = "Caricato."
L["name"] = "Nome"
L["name_desc"] = "Il nome che verrà visualizzato nei tuoi messaggi di chat."
L["party"] = "Gruppo"
L["party_desc"] = "Aggiunge il nome ai messaggi della chat di gruppo (/p)."
L["raid"] = "Incursione"
L["raid_desc"] = "Aggiunge il nome ai messaggi della chat di incursione (/raid)."
L["ignoreExclamationMark"] = "Non aggiungere il nome ai messaggi che iniziano con !"
L["ignoreExclamationMark_desc"] = "Se un messaggio inizia con un punto esclamativo (!), il nome non verrà aggiunto. Utile per i comandi degli addon come !keys."

-- Messaggi di stato / avvertimento
L["hook_active_eventregistry"] = "Hook attivo (ChatFrame.OnEditBoxPreSendText)"
L["hook_active_mixin"] = "Hook attivo (ChatFrameEditBoxMixin.SendText fallback)"
L["hook_error_no_entry"] = "ERRORE: Nessun punto di ingresso trovato per l'hook."
L["hook_error_modify"] = "Errore durante la modifica del messaggio di chat: "
L["warn_restrictions_enforced"] = "Avviso: Le restrizioni di chat per gli addon sono ora attive. Le funzioni di Name2Chat potrebbero essere limitate."
L["warn_restrictions_lifted"] = "Le restrizioni di chat per gli addon sono state rimosse."

-- Messaggi di debug
L["debug_hook_fired"] = "ModifyChatMessage: hook attivato"
L["debug_disabled"] = "ModifyChatMessage: addon DISABILITATO, salto"
L["debug_name_empty"] = "ModifyChatMessage: nome VUOTO, salto"
L["debug_name_matches_char"] = "ModifyChatMessage: il nome coincide con quello del personaggio e hideOnMatchingCharName è attivo, salto"
L["debug_msg_empty"] = "ModifyChatMessage: messaggio vuoto, salto"
L["debug_chattype"] = "ModifyChatMessage: chatType=%s, nome=%s"
L["debug_should_add"] = "ModifyChatMessage: shouldAddName=%s"
L["debug_skip_exclamation"] = "ModifyChatMessage: salto, il messaggio inizia con ! (ignoreExclamationMark attivo)"
L["debug_modified"] = "ModifyChatMessage: OK -> %s"
L["debug_chattype_not_active"] = "ModifyChatMessage: chatType '%s' non è nell'elenco dei canali attivi. gilda=%s gruppo=%s incursione=%s"


