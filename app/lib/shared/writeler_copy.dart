final class WritelerLanguage {
  const WritelerLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });

  final String code;
  final String nativeName;
  final String englishName;
}

final class WritelerCopy {
  WritelerCopy(String languageCode)
      : languageCode = WritelerCopy.normalizeLanguageCode(languageCode);

  final String languageCode;

  static const fallbackLanguageCode = 'de';

  static const supportedLanguages = [
    WritelerLanguage(
      code: 'de',
      nativeName: 'Deutsch',
      englishName: 'German',
    ),
    WritelerLanguage(
      code: 'en',
      nativeName: 'English',
      englishName: 'English',
    ),
  ];

  static String normalizeLanguageCode(String value) {
    final normalized = value.trim().toLowerCase().split(RegExp('[-_]')).first;
    if (supportedLanguages.any((language) => language.code == normalized)) {
      return normalized;
    }
    return fallbackLanguageCode;
  }

  static WritelerLanguage languageFor(String languageCode) {
    final normalized = normalizeLanguageCode(languageCode);
    return supportedLanguages.firstWhere(
      (language) => language.code == normalized,
      orElse: () => supportedLanguages.first,
    );
  }

  static const _de = {
    'appTitle': 'Writeler',
    'dashboard': 'Dashboard',
    'projects': 'Projekte',
    'project': 'Projekt',
    'projectStructure': 'Projektstruktur',
    'editor': 'Editor',
    'scenes': 'Szenen',
    'scene': 'Szene',
    'chapters': 'Kapitel',
    'characters': 'Figuren',
    'character': 'Figur',
    'locations': 'Orte',
    'location': 'Ort',
    'objects': 'Objekte',
    'object': 'Objekt',
    'analysis': 'Analyse',
    'aiWorkshop': 'KI-Werkstatt',
    'exports': 'Export/Import',
    'selfPublishing': 'Veröffentlichung',
    'settings': 'Einstellungen',
    'navGroupWriting': 'Schreiben',
    'navGroupAnalysisAi': 'Analyse & KI',
    'navGroupAdministration': 'Verwaltung',
    'language': 'Sprache',
    'languageGerman': 'Deutsch',
    'languageEnglish': 'English',
    'designSettings': 'Design',
    'designSettingsBody':
        'Wähle die Arbeitsstimmung für Oberfläche, Marke und Fokusflächen.',
    'designThemePaper': 'Hell',
    'designThemeSystem': 'System',
    'designThemeDusk': 'Dunkel',
    'designThemeSapphire': 'Saphir',
    'designThemeSage': 'Salbei',
    'designThemeCopper': 'Kupfer',
    'designThemeInk': 'Tinte',
    'globalProfileSettings': 'Arbeitsprofil',
    'globalProfileSettingsBody':
        'Globale Vorgaben für alle Projekte. Projektabhängige Überschreibungen können später ergänzt werden.',
    'globalAiEnabledHint':
        'Steuert KI-Funktionen appweit, unabhängig vom aktuell geöffneten Projekt.',
    'globalCloudSyncHint':
        'Bereitet optionale Synchronisation appweit vor. Der aktuelle Adapter bleibt lokal/manuell.',
    'globalNoAiNoCloudHint':
        'Deaktiviert KI und Cloud-Sync appweit für einen strikt lokalen Arbeitsmodus.',
    'privacySettings': 'Projekt & Privatsphäre',
    'privacySettingsBody':
        'Steuert, wie dieses Projekt KI und optionale Synchronisation nutzt.',
    'providerSettingsBody':
        'Provider, Modell und API-Key für KI-Funktionen konfigurieren.',
    'emptyTitle': 'Noch kein Projekt geöffnet',
    'emptyBody':
        'Lege ein lokales Schreibprojekt an und strukturiere es in Kapitel, Szenen und Notizen.',
    'dashboardBody':
        'Projektstatus, offene Strukturpunkte und nächste Arbeitsschritte an einem Ort.',
    'openEditor': 'Editor öffnen',
    'projectPulse': 'Projektpuls',
    'nextActions': 'Nächste Schritte',
    'nextActionsBody':
        'Direkte Wege zu den Stellen, die gerade Aufmerksamkeit brauchen.',
    'continueWriting': 'Weiterschreiben',
    'reviewStructure': 'Struktur prüfen',
    'reviewSuggestions': 'KI-Vorschläge prüfen',
    'reviewNotes': 'Notizen sichten',
    'nextSceneWithoutText': 'Nächste Szene ohne Text',
    'mostUrgentPlanningGap': 'Dringendste Planungslücke',
    'latestOpenAiResponse': 'Letzte KI-Antwort offen',
    'noteWithoutTarget': 'Notiz ohne Ziel',
    'noDashboardActions': 'Keine dringenden nächsten Schritte.',
    'structureFocus': 'Strukturstatus',
    'structureFocusBody':
        'Planung, Zuordnung und Katalogbindung für das aktuelle Projekt.',
    'emptyDraftScenes': 'Szenen ohne Manuskript',
    'recentScenesBody':
        'Zuletzt bearbeitete Szenen mit Wortstand und Planungsstatus.',
    'noRecentScenes': 'Noch keine Szenen im Projekt.',
    'activityStream': 'Aktivität',
    'activityStreamBody': 'Lokale Ereignisse aus Schreiben, KI und Export.',
    'noActivityYet': 'Noch keine Aktivität für dieses Projekt.',
    'protocols': 'Protokolle',
    'protocolsBody':
        'Chronologische Ereignisse des aktuellen Projekts: Schreiben, KI, Export, Import und Sync.',
    'noProtocolsYet': 'Noch keine Protokolle für dieses Projekt.',
    'dashboardSignals': 'Signale',
    'dashboardSignalsBody':
        'Kurzstatus für KI, Notizen und heutige Schreibarbeit.',
    'aiQueue': 'KI-Warteschlange',
    'notesQueue': 'Notizen',
    'newProject': 'Neues Projekt',
    'projectTitle': 'Projekttitel',
    'projectWizardBasics': 'Projekt benennen',
    'projectWizardAuthor': 'Autor und Form',
    'projectWizardScope': 'Umfang und Notiz',
    'authorName': 'Autorenname',
    'projectType': 'Projektart',
    'projectTypeNovel': 'Roman',
    'projectTypeShortStory': 'Kurzgeschichte',
    'projectTypeNonfiction': 'Sachbuch',
    'projectLanguage': 'Projektsprache',
    'projectDescription': 'Projektbeschreibung',
    'projectMetadata': 'Projektangaben',
    'projectMetadataBody':
        'Projektbezogene Angaben, die Export, Self-Publishing und KI-Kontext nutzen können.',
    'selectProjectForMetadata':
        'Wähle ein Projekt aus, um Projektangaben zu bearbeiten.',
    'saveProjectMetadata': 'Projektangaben speichern',
    'step': 'Schritt',
    'back': 'Zurück',
    'next': 'Weiter',
    'create': 'Anlegen',
    'cancel': 'Abbrechen',
    'delete': 'Löschen',
    'deletePermanently': 'Endgültig löschen',
    'deleteProject': 'Projekt löschen',
    'deleteChapter': 'Kapitel löschen',
    'deleteScene': 'Szene löschen',
    'deleteCatalogItem': 'Eintrag löschen',
    'deleteProjectBody':
        'Dieses Projekt und alle lokalen Kapitel, Szenen, Katalogeinträge, Vorschläge und Metriken werden entfernt.',
    'deleteChapterBody':
        'Das Kapitel wird entfernt. Seine Szenen bleiben erhalten und werden ohne Kapitel einsortiert.',
    'deleteSceneBody':
        'Diese Szene und ihre Kontextverknüpfungen werden entfernt.',
    'deleteCatalogItemBody':
        'Dieser Katalogeintrag und seine Kontextverknüpfungen werden entfernt.',
    'projectDeleted': 'Projekt gelöscht',
    'chapterDeleted': 'Kapitel gelöscht',
    'sceneDeleted': 'Szene gelöscht',
    'catalogItemDeleted': 'Katalogeintrag gelöscht',
    'untitledProject': 'Unbenanntes Projekt',
    'localOnly': 'Lokal',
    'projectCreated': 'Projekt angelegt',
    'newScene': 'Neue Szene',
    'newChapter': 'Neues Kapitel',
    'chapter': 'Kapitel',
    'chapterTitle': 'Kapiteltitel',
    'untitledChapter': 'Unbenanntes Kapitel',
    'chapterCreated': 'Kapitel angelegt',
    'noChapter': 'Ohne Kapitel',
    'sceneTitle': 'Szenentitel',
    'untitledScene': 'Unbenannte Szene',
    'sceneCreated': 'Szene angelegt',
    'noScenesTitle': 'Noch keine Szenen',
    'noScenesBody':
        'Lege eine Szene an, um Manuskript, Ziel, Konflikt und Ausgang zu planen.',
    'manuscript': 'Manuskript',
    'saveScene': 'Szene speichern',
    'sceneSaved': 'Szene gespeichert',
    'selectScene': 'Wähle eine Szene aus',
    'words': 'Wörter',
    'characterCount': 'Zeichen',
    'targetProgress': 'Wortziel',
    'focusMode': 'Fokusmodus',
    'exitFocusMode': 'Fokusmodus verlassen',
    'searchReplace': 'Suchen und ersetzen',
    'editorFontSize': 'Manuskriptschriftgröße',
    'findText': 'Suchen',
    'replaceWith': 'Ersetzen durch',
    'matches': 'Treffer',
    'nextMatch': 'Nächster Treffer',
    'replaceNext': 'Nächstes ersetzen',
    'replaceAll': 'Alle ersetzen',
    'autosaveSaved': 'Gespeichert',
    'autosavePending': 'Ungespeichert',
    'autosaveSaving': 'Speichert...',
    'autosaveError': 'Speichern fehlgeschlagen',
    'sceneInspector': 'Szenen-Inspektor',
    'summary': 'Zusammenfassung',
    'goal': 'Ziel',
    'conflict': 'Konflikt',
    'outcome': 'Ausgang',
    'status': 'Status',
    'wordTarget': 'Wortziel',
    'catalog': 'Katalog',
    'name': 'Name',
    'newCharacter': 'Neue Figur',
    'newLocation': 'Neuer Ort',
    'newObject': 'Neues Objekt',
    'newCatalogItem': 'Neuer Eintrag',
    'editCatalogItem': 'Eintrag bearbeiten',
    'saveCatalogItem': 'Eintrag speichern',
    'untitledCharacter': 'Unbenannte Figur',
    'untitledLocation': 'Unbenannter Ort',
    'untitledObject': 'Unbenanntes Objekt',
    'untitledCatalogItem': 'Unbenannter Eintrag',
    'catalogItemCreated': 'Katalogeintrag angelegt',
    'catalogItemSaved': 'Katalogeintrag gespeichert',
    'noCharactersTitle': 'Noch keine Figuren',
    'noLocationsTitle': 'Noch keine Orte',
    'noObjectsTitle': 'Noch keine Objekte',
    'noCatalogItemsTitle': 'Noch keine Einträge',
    'catalogEmptyBody':
        'Lege Profile an und nutze sie als Kontext für Szenen, Analyse und KI-Vorschläge.',
    'noSummary': 'Keine Zusammenfassung',
    'sceneContext': 'Szenenkontext',
    'sceneContextEmpty':
        'Lege Figuren, Orte oder Objekte an, um sie mit dieser Szene zu verknüpfen.',
    'relationships': 'Verknüpfungen',
    'openSuggestions': 'Offene Vorschläge',
    'metricEvents': 'Lokale Events',
    'todaySaves': 'Speicherungen heute',
    'aiUses': 'KI-Nutzung',
    'recentMetrics': 'Letzte lokale Ereignisse',
    'noMetricsYet': 'Noch keine lokalen Metriken für dieses Projekt.',
    'workspace': 'Arbeitsbereich',
    'commandPalette': 'Befehlspalette',
    'searchCommands': 'Befehl, Szene oder Entität suchen',
    'noCommandMatches': 'Keine Treffer.',
    'recentScenes': 'Aktuelle Szenen',
    'sceneBoard': 'Szenenboard',
    'relationshipGraph': 'Beziehungsgraph',
    'statistics': 'Statistiken',
    'statisticsBody': 'Messwerte zum aktuellen Projekt.',
    'inProgress': 'In Arbeit',
    'done': 'Fertig',
    'lockedOrArchived': 'Gesperrt oder archiviert',
    'noScenesInStatus': 'Keine Szenen in diesem Status.',
    'chooseStatus': 'Status auswählen',
    'structureCockpit': 'Struktur-Cockpit',
    'planningGaps': 'Planungslücken',
    'unassignedScenes': 'Ohne Kapitel',
    'timeline': 'Timeline',
    'unscheduled': 'Ohne Datum',
    'statusSpread': 'Statusverteilung',
    'datedScenes': 'Datierte Szenen',
    'chapterOverview': 'Kapitelüberblick',
    'structureInspector': 'Struktur-Inspektor',
    'authorStructureCockpit': 'Autoren-Cockpit',
    'authorStructureCockpitBody':
        'Szenenfluss, offene Konflikte, Entitäten und Muster im aktuellen Projekt.',
    'structureComplete': 'Planung vollständig',
    'missing': 'Fehlt',
    'openScene': 'Szene öffnen',
    'noPlanningGaps': 'Keine offenen Planungslücken',
    'openConflicts': 'Offene Konflikte',
    'noOpenConflicts': 'Keine offenen Konflikte',
    'noUnscheduledScenes': 'Alle Szenen haben ein Datum',
    'noTimelineScenes': 'Noch keine datierten Szenen',
    'timelineBody':
        'Szenen nach erzählter Zeit. Undatierte Szenen bleiben darunter sichtbar.',
    'noDatedScenes': 'Noch keine datierten Szenen.',
    'undatedScenes': 'Undatierte Szenen',
    'noUndatedScenes': 'Alle Szenen haben ein Datum.',
    'withoutDate': 'Ohne Datum',
    'entityWeb': 'Entitätsnetz',
    'motifTracker': 'Motiv-Tracker',
    'noMotifsYet': 'Noch keine Muster aus Szenentyp, Ton oder Status.',
    'relationshipMap': 'Beziehungskarte',
    'noRelationshipsYet': 'Noch keine Beziehungen verknüpft.',
    'noRelationshipsTitle': 'Noch keine Beziehungen',
    'noRelationshipsBody':
        'Lege Beziehungen zwischen Figuren, Orten, Objekten oder Szenen an.',
    'relationshipNeedsEndpoints':
        'Lege zuerst mindestens zwei Szenen, Figuren, Orte oder Objekte an.',
    'strength': 'Stärke',
    'entityDetails': 'Entitätsdetails',
    'newRelationship': 'Neue Beziehung',
    'editRelationship': 'Beziehung bearbeiten',
    'deleteRelationship': 'Beziehung löschen',
    'deleteRelationshipBody': 'Diese Beziehung wird aus dem Projekt entfernt.',
    'saveRelationship': 'Beziehung speichern',
    'relationshipSaved': 'Beziehung gespeichert',
    'relationshipDeleted': 'Beziehung gelöscht',
    'relationshipSource': 'Quelle',
    'relationshipTarget': 'Ziel',
    'relationshipType': 'Beziehungstyp',
    'relationshipLabel': 'Label',
    'relationshipDescription': 'Beschreibung',
    'relationshipStrength': 'Stärke',
    'relationshipDirected': 'Gerichtet',
    'relationshipUndirected': 'Beidseitig',
    'relationTypeAppearsIn': 'tritt auf in',
    'relationTypeAlly': 'Verbündete',
    'relationTypeConflict': 'Konflikt',
    'relationTypeFamily': 'Familie',
    'relationTypeOwns': 'Besitzt',
    'relationTypeLocatedAt': 'Ortbezug',
    'relationTypeForeshadows': 'Foreshadowing',
    'relationTypeCustom': 'Eigener Typ',
    'sceneType': 'Szenentyp',
    'emotionalTone': 'Ton',
    'storyAnalysis': 'Storyline & Analyse',
    'storylineHealth': 'Storyline-Prüfung',
    'chapterBalance': 'Kapitelbalance',
    'catalogPresence': 'Präsenzmatrix',
    'openPlanningGaps': 'Offene Planungslücken',
    'scenesWithoutPov': 'Szenen ohne Perspektive',
    'scenesWithoutDate': 'Szenen ohne Datum',
    'detachedCatalogItems': 'Einträge ohne Auftritt',
    'missingStructure': 'Ziel, Konflikt oder Ausgang fehlt',
    'noAnalysisIssues': 'Keine akuten Strukturhinweise.',
    'noAppearances': 'Keine Auftritte',
    'appearances': 'Auftritte',
    'linkedScenes': 'Verknüpfte Szenen',
    'wordsPerChapter': 'Wörter pro Kapitel',
    'structureActions': 'Strukturaktionen',
    'moveSceneUp': 'Szene nach oben',
    'moveSceneDown': 'Szene nach unten',
    'moveToChapter': 'In Kapitel verschieben',
    'moveToNoChapter': 'Ohne Kapitel',
    'aiNeedsScene':
        'Lege zuerst eine Szene an, bevor KI-Vorschläge erzeugt werden.',
    'aiContext': 'Kontext',
    'aiProjectContext': 'Projekt',
    'aiSceneContext': 'Szene',
    'selectAiScene': 'Szenenkontext wählen',
    'aiProjectScopeHint':
        'Projektweite Analyse nutzt Titel, Beschreibung, Kapitel und Szenenüberblick.',
    'aiPrompt': 'Auftrag an die KI',
    'defaultAiPrompt':
        'Prüfe diese Szene und schlage strukturierende Fragen vor.',
    'editorAiHelp': 'KI-Hilfe',
    'editorAiHelpInput': 'Frage oder Auftrag zur aktuellen Szene',
    'helpEditorAiHelp':
        'Nutzt den Kontext der aktuellen Szene und speichert die Antwort als KI-Vorschlag.',
    'sendAiHelp': 'KI fragen',
    'latestAiHelpAnswer': 'Letzte Antwort',
    'defaultEditorAiHelpPrompt':
        'Analysiere die aktuelle Szene und nenne die hilfreichsten nächsten Entscheidungen.',
    'requestSceneIdeas': 'Szenenideen',
    'requestStructure': 'Ziel/Konflikt/Ausgang',
    'moreAiChecks': 'Weitere Prüfungen',
    'submitAiPrompt': 'Auftrag senden',
    'aiPromptSubmitHint': 'Strg+Enter sendet den Auftrag',
    'promptTemplates': 'Prompt-Vorlagen',
    'promptPreview': 'Exakter Prompt an das LLM',
    'structuredAnswer': 'Strukturierte Antwort',
    'promptTemplateSceneIdeas':
        'Entwickle drei unterschiedliche Szenenvarianten. Benenne jeweils Konflikt, neue Information und erzählerischen Nutzen.',
    'promptTemplateSceneStructure':
        'Prüfe Ziel, Konflikt, Ausgang und Zusammenfassung. Gib zuerst einen JSON-Block für scenePatch aus und danach kurze Begründungen.',
    'promptTemplateConsistency':
        'Suche konkrete Anschluss-, Fakten- und Logikprobleme. Nenne je Punkt die betroffene Information und eine pragmatische Korrektur.',
    'promptTemplateTimeline':
        'Prüfe zeitliche Abfolge, Dauer, Ortswechsel und Erholungszeiten. Markiere unklare Stellen und schlage eine plausible Reihenfolge vor.',
    'promptTemplatePlotGaps':
        'Finde Plot-Lücken, fehlende Motivation und unklare Kausalität. Priorisiere nach Risiko für die Story.',
    'promptTemplateAuthorQuestions':
        'Formuliere starke Autorfragen, die Entscheidungen erzwingen. Keine allgemeinen Tipps, nur konkrete Fragen zur Szene.',
    'promptTemplateStyle':
        'Analysiere Ton, Rhythmus, Perspektive und Stilwirkung. Gib konkrete Stellschrauben, ohne Manuskripttext zu ersetzen.',
    'promptTemplateResearch':
        'Strukturiere offene Recherchefragen in Sofort klären, später prüfen und kann fiktional gelöst werden.',
    'promptTemplateDialogue':
        'Analysiere Dialogabsicht, Subtext, Machtverschiebung und unausgesprochene Ziele der Figuren.',
    'promptTemplateCharacter':
        'Prüfe Figurenfunktion, Ziel, Widerspruch und Veränderungspotenzial im Szenenkontext.',
    'promptTemplateStoryline':
        'Entwickle alternative Storyline-Varianten mit Folgen für Konflikt, Tempo und Figurenentscheidung.',
    'promptTemplateBlurb':
        'Entwickle Pitch- oder Klappentext-Varianten, ohne finalen Manuskripttext zu ersetzen.',
    'aiApiKeyMissing':
        'Für diesen Provider ist ein API-Key nötig. Speichere ihn unter Einstellungen > Provider-Konfiguration.',
    'aiRequestInProgress': 'Provider-Anfrage läuft...',
    'aiRequestFailed': 'Provider-Anfrage fehlgeschlagen',
    'aiSuggestionCreated': 'KI-Vorschlag gespeichert',
    'aiMockProviderActive':
        'Mock / lokal ist aktiv - Antworten sind Demo-Platzhalter. Speichere OpenRouter oder einen anderen Provider in den Einstellungen.',
    'aiTaskCustomScenePrompt': 'Eigener KI-Auftrag',
    'aiTaskCharacterProfile': 'Figurenprofil',
    'aiTaskConsistencyCheck': 'Konsistenzprüfung',
    'aiTaskTimelineCheck': 'Timeline-Prüfung',
    'aiTaskStorylineVariants': 'Storyline-Varianten',
    'aiTaskBlurbVariants': 'Klappentext-Varianten',
    'aiTaskStyleAnalysis': 'Stilanalyse',
    'aiTaskAuthorQuestions': 'Autorenfragen',
    'aiTaskResearchStructuring': 'Recherche strukturieren',
    'aiTaskPlotGapReview': 'Plot-Lücken prüfen',
    'aiTaskDialogueIntentAnalysis': 'Dialogabsicht analysieren',
    'suggestions': 'Vorschläge',
    'noSuggestions': 'Noch keine Vorschläge',
    'notes': 'Notizen',
    'noNotes': 'Noch keine Notizen',
    'notesCockpit': 'Notizen-Cockpit',
    'newNote': 'Neue Notiz',
    'editNote': 'Notiz bearbeiten',
    'untitledNote': 'Unbenannte Notiz',
    'noteTitle': 'Titel',
    'noteBody': 'Notiz',
    'noteTarget': 'Ziel',
    'targetProject': 'Projekt allgemein',
    'searchNotes': 'Notizen suchen',
    'allNotes': 'Alle',
    'projectNotes': 'Projekt',
    'sceneNotes': 'Szenen',
    'catalogNotes': 'Katalog',
    'manualNotes': 'Manuell',
    'aiNotes': 'KI',
    'manualNote': 'Manuelle Notiz',
    'aiNote': 'KI-Notiz',
    'noNotesForFilter': 'Keine passenden Notizen',
    'noNoteSelectedTitle': 'Keine Notiz ausgewählt',
    'noNoteSelectedBody':
        'Lege eine Notiz an oder wähle links einen Eintrag aus.',
    'openLinkedScene': 'Verknüpfte Szene öffnen',
    'saveNote': 'Notiz speichern',
    'noteCreated': 'Notiz angelegt',
    'noteSaved': 'Notiz gespeichert',
    'noteDeleted': 'Notiz gelöscht',
    'aiResponse': 'Antwort',
    'sentPrompt': 'Gesendeter Prompt',
    'suggestionPending': 'offen',
    'suggestionAccepted': 'angenommen',
    'suggestionRejected': 'abgelehnt',
    'suggestionConverted': 'als Notiz gesichert',
    'suggestionAcceptedFeedback': 'Vorschlag angenommen',
    'suggestionAppliedFeedback': 'Vorschlag auf Szenenplanung angewendet',
    'suggestionAcceptedNoPatchFeedback':
        'Vorschlag angenommen, keine Planungsfelder geändert',
    'suggestionDeletedFeedback': 'Vorschlag gelöscht',
    'suggestionConvertedFeedback': 'Notiz aus Vorschlag erstellt',
    'applyPreview': 'Änderungsvorschau',
    'noApplyPreview':
        'Keine übernehmbaren Szenenfelder erkannt. Annehmen markiert den Vorschlag nur als geprüft.',
    'accept': 'Annehmen',
    'reject': 'Ablehnen',
    'convertToNote': 'Als Notiz markieren',
    'exportPreview': 'Exportvorschau',
    'copyExport': 'Export kopieren',
    'downloadExport': 'Export herunterladen',
    'exportCopied': 'Export in die Zwischenablage kopiert',
    'exportDownloaded': 'Export heruntergeladen',
    'exportCancelled': 'Export abgebrochen',
    'archiveExportBody':
        'Vollständiges Writeler-Archiv für Backup, Umzug oder Import in eine andere Writeler-Instanz.',
    'selfPublishingBody':
        'Lesbares Manuskript für Weitergabe, Lektorat oder Veröffentlichung.',
    'publishingFormat': 'Ausgabeformat',
    'downloadManuscript': 'Manuskript herunterladen',
    'includePublishingMetadata': 'Notizen und Projektinfo einschließen',
    'syncCheckpoint': 'Sync-Checkpoint',
    'syncCheckpointBody':
        'Erzeugt ein vollständiges, lokales Sync-Paket für manuelle Ablage, WebDAV oder spätere Cloud-Adapter.',
    'copySyncCheckpoint': 'Sync-Checkpoint kopieren',
    'syncCheckpointCopied': 'Sync-Checkpoint in die Zwischenablage kopiert',
    'lastSyncCheckpoint': 'Letzter Checkpoint',
    'syncFingerprint': 'Fingerprint',
    'syncPayloadSize': 'Paketgröße',
    'syncPayloadDetected': 'Sync-Paket erkannt',
    'syncAdapter': 'Sync-Adapter',
    'syncAdapterHint':
        'Lokale Nutzung bleibt unabhängig; Cloud-Sync ist nur ein optionaler Adapter.',
    'importArchive': 'Projekt importieren',
    'archiveSchema': 'Archivschema',
    'chooseImportFile': 'Importdatei wählen',
    'dropImportFile': 'Datei hier ablegen',
    'dropImportFileBody':
        'Writeler JSON, yWriter (.yw5/.yw6/.yw7), Scrivener (.scrivx), Markdown oder TXT',
    'selectedImportFile': 'Ausgewählte Datei',
    'importSourceType': 'Importtyp',
    'archivePreviewInvalid': 'Archivvorschau nicht möglich',
    'pasteArchiveJson': 'JSON, yWriter-XML oder Text hier einfügen',
    'importProject': 'Projekt importieren',
    'importComplete': 'Projektarchiv importiert',
    'helpCopyExport':
        'Kopiert die aktuell angezeigte Exportvorschau mit den gewählten Einstellungen in die Zwischenablage.',
    'helpExportFormat':
        'Der Export ist ein vollständiges Writeler-Archiv mit allen Projektdaten für den späteren Import.',
    'helpPublishingFormat':
        'Legt fest, in welchem lesbaren Manuskriptformat die Veröffentlichung ausgegeben wird.',
    'helpIncludeSceneTitles':
        'Fügt beim Export die Szenentitel vor den jeweiligen Textabschnitten ein.',
    'helpIncludeMetadata':
        'Nimmt Planungsdaten wie Status, Ziel, Konflikt und Ausgang in den Export auf.',
    'helpIncludePublishingMetadata':
        'Hängt Projektinfo und Notizen an das Manuskript an. Der reine Romantext bleibt ansonsten im Vordergrund.',
    'helpDownloadExport':
        'Erstellt eine vollständige Writeler-Archivdatei und speichert sie lokal.',
    'helpDownloadManuscript':
        'Erstellt eine lesbare Manuskriptdatei im gewählten Format und speichert sie lokal.',
    'helpCopySyncCheckpoint':
        'Kopiert ein vollständiges lokales Sync-Paket, das später wieder importiert werden kann.',
    'helpImportFile':
        'Lädt eine Datei und erkennt automatisch Writeler, yWriter, Scrivener, Markdown oder Text.',
    'helpPasteImport':
        'Prüft eingefügten Inhalt und zeigt vor dem Import eine Vorschau des erkannten Projekts.',
    'helpImportProject':
        'Legt aus der Vorschau ein neues lokales Projekt mit Kapiteln, Szenen und Katalogdaten an.',
    'format': 'Format',
    'includeSceneTitles': 'Szenentitel einschließen',
    'includeMetadata': 'Metadaten einschließen',
    'nothingToExport': 'Noch nichts zu exportieren',
    'selectProject': 'Wähle ein Projekt aus',
    'aiEnabled': 'KI-Unterstützung',
    'cloudSyncEnabled': 'Cloud-Sync',
    'noAiNoCloud': 'No AI / No Cloud',
    'providerConfig': 'Provider-Konfiguration',
    'providerKind': 'Provider-Typ',
    'providerEnabled': 'Provider aktiv',
    'providerName': 'Providername',
    'modelName': 'Modellname',
    'baseUrl': 'Base-URL',
    'apiKeyRef': 'API-Key',
    'apiKeyWebWarning':
        'Wird getrennt von der Provider-Konfiguration sicher lokal gespeichert.',
    'apiKeyStoredHint':
        'API-Key ist sicher gespeichert. Leer lassen, um ihn beizubehalten.',
    'deleteApiKey': 'API-Key entfernen',
    'apiKeyDeleted': 'API-Key entfernt',
    'saveProviderConfig': 'Provider speichern',
    'providerConfigSaved': 'Provider-Konfiguration gespeichert',
    'helpDesignSettings':
        'Ändert nur die Darstellung der App. Inhalte und Projekte bleiben unverändert.',
    'helpGlobalProfileSettings':
        'Diese Optionen gelten appweit, solange spätere Projektprofile sie nicht überschreiben.',
    'helpProjectMetadata':
        'Speichert Angaben zum aktuellen Projekt, zum Beispiel den Autorennamen.',
    'helpAiEnabled':
        'Schaltet KI-Funktionen global ein oder aus. Manuskripttext wird dadurch nicht automatisch verändert.',
    'helpCloudSyncEnabled':
        'Erlaubt spätere Cloud-Sync-Adapter. Lokale Arbeit bleibt weiterhin möglich.',
    'helpNoAiNoCloud':
        'Deaktiviert KI und Cloud-Sync gemeinsam für einen bewusst lokalen Arbeitsmodus.',
    'helpProviderKind':
        'Wählt die technische Schnittstelle für KI-Anfragen, zum Beispiel OpenRouter, OpenAI oder Ollama.',
    'helpProviderEnabled':
        'Aktiviert oder pausiert den konfigurierten KI-Provider, ohne die gespeicherten Daten zu löschen.',
    'helpProviderName':
        'Ein frei wählbarer Anzeigename, damit du den Provider später wiedererkennst.',
    'helpModelName':
        'Der genaue Modellname, der an den Provider gesendet wird.',
    'helpBaseUrl':
        'Die API-Adresse des Providers. Bei Presets wird sie automatisch vorbelegt.',
    'helpApiKey':
        'Der Schlüssel wird lokal gespeichert und für echte Provider-Anfragen verwendet.',
    'helpDeleteApiKey':
        'Entfernt nur den lokal gespeicherten API-Key. Die übrige Provider-Konfiguration bleibt erhalten.',
    'helpSaveProviderConfig':
        'Speichert Provider, Modell, URL, Aktivstatus und optional den API-Key für zukünftige KI-Anfragen.',
    'helpAiContext':
        'Der Kontext bestimmt, ob die KI über das ganze Projekt oder nur über eine ausgewählte Szene nachdenkt.',
    'helpPromptTemplates':
        'Füllt den Auftrag mit einem passenden Startprompt. Du kannst den Text vor dem Senden frei ändern.',
    'helpSubmitAiPrompt':
        'Sendet den sichtbaren Auftrag mit dem gewählten Kontext an den aktiven KI-Provider und speichert die Antwort als Vorschlag.',
    'helpAiQuickActions':
        'Diese Aktionen senden sofort spezialisierte Prüf- oder Ideenaufträge an die KI.',
    'helpPromptPreview':
        'Zeigt den vollständigen Prompt, der tatsächlich an das Sprachmodell gesendet wird.',
    'helpSuggestionActions':
        'Annehmen prüft und übernimmt erkannte Planungsfelder, Notiz erstellt eine Projektnotiz, Ablehnen löscht den Vorschlag.',
    'helpAcceptSuggestion':
        'Übernimmt erkannte Strukturfelder in die Szene oder markiert den Vorschlag als geprüft.',
    'helpConvertSuggestion':
        'Speichert die KI-Antwort als Notiz, damit sie später weiterverwendet werden kann.',
    'helpRejectSuggestion': 'Löscht den Vorschlag aus der offenen KI-Liste.',
    'helpNewProject':
        'Legt ein neues lokales Schreibprojekt an. Bestehende Projekte bleiben unverändert.',
    'helpNewScene':
        'Erstellt eine neue Szene im aktuellen Projekt und öffnet sie zur Bearbeitung.',
    'helpNewChapter':
        'Erstellt ein neues Kapitel, dem Szenen zugeordnet werden können.',
    'helpDeleteChapter':
        'Löscht das Kapitel nach Rückfrage. Zugeordnete Szenen bleiben im Projekt erhalten.',
    'helpNewCatalogItem':
        'Legt eine neue Person, einen Ort oder ein Objekt im aktuellen Katalog an.',
    'helpEditCatalogItem':
        'Öffnet die Detailansicht, damit Name, Status und Beschreibung bearbeitet werden können.',
    'helpDeleteCatalogItem':
        'Löscht den Katalogeintrag nach Rückfrage aus dem Projekt.',
    'helpSaveCatalogItem':
        'Speichert Name, Status, Beschreibung und Zusatzfelder dieses Katalogeintrags.',
    'helpNewNote':
        'Erstellt eine neue Notiz, die dem Projekt, einer Szene oder einem Katalogeintrag zugeordnet werden kann.',
    'helpOpenLinkedScene':
        'Springt direkt zu der Szene, auf die diese Notiz verweist.',
    'helpSaveNote':
        'Speichert Titel, Ziel und Inhalt der aktuellen Notiz lokal.',
    'helpDeleteNote': 'Löscht die ausgewählte Notiz aus dem Projekt.',
    'helpNewRelationship':
        'Legt eine Beziehung zwischen Figuren, Orten, Objekten oder Szenen an.',
    'helpEditRelationship':
        'Öffnet die Beziehung, damit Typ, Richtung, Stärke und Beschreibung angepasst werden können.',
    'helpDeleteRelationship':
        'Löscht nur diese Beziehung. Die verknüpften Entitäten bleiben erhalten.',
    'helpSaveRelationship':
        'Speichert Quelle, Ziel, Typ, Richtung, Stärke und Beschreibung dieser Beziehung.',
    'helpDeletePermanently':
        'Bestätigt den Löschvorgang endgültig. Diese Aktion lässt sich nicht automatisch rückgängig machen.',
    'helpStructureActions':
        'Öffnet Aktionen für diese Szene: verschieben, Kapitel ändern oder löschen.',
    'activeProvider': 'Aktiver Provider',
    'providerNameFallback': 'Lokaler Provider',
    'modelNameFallback': 'mock-structure-v1',
  };

  static const _en = {
    'appTitle': 'Writeler',
    'dashboard': 'Dashboard',
    'projects': 'Projects',
    'project': 'Project',
    'projectStructure': 'Project structure',
    'editor': 'Editor',
    'scenes': 'Scenes',
    'scene': 'Scene',
    'chapters': 'Chapters',
    'characters': 'Characters',
    'character': 'Character',
    'characterCount': 'Characters',
    'locations': 'Locations',
    'location': 'Location',
    'objects': 'Objects',
    'object': 'Object',
    'analysis': 'Analysis',
    'aiWorkshop': 'AI Workshop',
    'exports': 'Export/Import',
    'selfPublishing': 'Self-publishing',
    'settings': 'Settings',
    'navGroupWriting': 'Writing',
    'navGroupAnalysisAi': 'Analysis & AI',
    'navGroupAdministration': 'Administration',
    'language': 'Language',
    'languageGerman': 'Deutsch',
    'languageEnglish': 'English',
    'designSettings': 'Design',
    'designSettingsBody':
        'Choose the working mood for the interface, brand, and focus surfaces.',
    'designThemePaper': 'Light',
    'designThemeSystem': 'System',
    'designThemeDusk': 'Dark',
    'designThemeSapphire': 'Sapphire',
    'designThemeSage': 'Sage',
    'designThemeCopper': 'Copper',
    'designThemeInk': 'Ink',
    'globalProfileSettings': 'Work profile',
    'globalProfileSettingsBody':
        'Global defaults for all projects. Project-specific overrides can be added later.',
    'globalAiEnabledHint':
        'Controls AI features app-wide, independent of the currently open project.',
    'globalCloudSyncHint':
        'Prepares optional sync app-wide. The current adapter remains local/manual.',
    'globalNoAiNoCloudHint':
        'Disables AI and cloud sync app-wide for a strictly local working mode.',
    'privacySettings': 'Project & privacy',
    'privacySettingsBody':
        'Controls how this project uses AI and optional sync.',
    'providerSettingsBody':
        'Configure provider, model, and API key for AI features.',
    'emptyTitle': 'No project open',
    'emptyBody':
        'Create a local writing project and organize it into chapters, scenes, and notes.',
    'dashboardBody':
        'Project status, open structure points, and next work steps in one place.',
    'openEditor': 'Open editor',
    'projectPulse': 'Project pulse',
    'nextActions': 'Next steps',
    'nextActionsBody':
        'Direct routes to the areas that currently need attention.',
    'continueWriting': 'Continue writing',
    'reviewStructure': 'Review structure',
    'reviewSuggestions': 'Review AI suggestions',
    'reviewNotes': 'Review notes',
    'nextSceneWithoutText': 'Next scene without text',
    'mostUrgentPlanningGap': 'Most urgent planning gap',
    'latestOpenAiResponse': 'Latest open AI response',
    'noteWithoutTarget': 'Note without target',
    'noDashboardActions': 'No urgent next steps.',
    'structureFocus': 'Structure status',
    'structureFocusBody':
        'Planning, assignment, and catalog links for the current project.',
    'emptyDraftScenes': 'Scenes without manuscript',
    'recentScenesBody':
        'Recently edited scenes with word count and planning status.',
    'noRecentScenes': 'No scenes in this project yet.',
    'activityStream': 'Activity',
    'activityStreamBody': 'Local events from writing, AI, and export.',
    'noActivityYet': 'No activity for this project yet.',
    'protocols': 'Logs',
    'protocolsBody':
        'Chronological events for the current project: writing, AI, export, import, and sync.',
    'noProtocolsYet': 'No logs for this project yet.',
    'dashboardSignals': 'Signals',
    'dashboardSignalsBody':
        'Short status for AI, notes, and today writing work.',
    'aiQueue': 'AI queue',
    'notesQueue': 'Notes',
    'newProject': 'New Project',
    'projectTitle': 'Project title',
    'projectWizardBasics': 'Name the project',
    'projectWizardAuthor': 'Author and form',
    'projectWizardScope': 'Scope and note',
    'authorName': 'Author name',
    'projectType': 'Project type',
    'projectTypeNovel': 'Novel',
    'projectTypeShortStory': 'Short story',
    'projectTypeNonfiction': 'Nonfiction',
    'projectLanguage': 'Project language',
    'projectDescription': 'Project description',
    'projectMetadata': 'Project details',
    'projectMetadataBody':
        'Project-specific details that export, self-publishing, and AI context can use.',
    'selectProjectForMetadata': 'Select a project to edit project details.',
    'saveProjectMetadata': 'Save project details',
    'step': 'Step',
    'back': 'Back',
    'next': 'Next',
    'create': 'Create',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'deletePermanently': 'Delete permanently',
    'deleteProject': 'Delete project',
    'deleteChapter': 'Delete chapter',
    'deleteScene': 'Delete scene',
    'deleteCatalogItem': 'Delete entry',
    'deleteProjectBody':
        'This project and all local chapters, scenes, catalog entries, suggestions, and metrics will be removed.',
    'deleteChapterBody':
        'The chapter will be removed. Its scenes stay available and move to no chapter.',
    'deleteSceneBody': 'This scene and its context links will be removed.',
    'deleteCatalogItemBody':
        'This catalog entry and its context links will be removed.',
    'projectDeleted': 'Project deleted',
    'chapterDeleted': 'Chapter deleted',
    'sceneDeleted': 'Scene deleted',
    'catalogItemDeleted': 'Catalog item deleted',
    'untitledProject': 'Untitled Project',
    'localOnly': 'Local',
    'projectCreated': 'Project created',
    'newScene': 'New Scene',
    'newChapter': 'New Chapter',
    'chapter': 'Chapter',
    'chapterTitle': 'Chapter title',
    'untitledChapter': 'Untitled Chapter',
    'chapterCreated': 'Chapter created',
    'noChapter': 'No chapter',
    'sceneTitle': 'Scene title',
    'untitledScene': 'Untitled Scene',
    'sceneCreated': 'Scene created',
    'noScenesTitle': 'No scenes yet',
    'noScenesBody':
        'Create a scene to plan manuscript, goal, conflict, and outcome.',
    'manuscript': 'Manuscript',
    'saveScene': 'Save Scene',
    'sceneSaved': 'Scene saved',
    'selectScene': 'Select a scene',
    'words': 'words',
    'targetProgress': 'Word target',
    'focusMode': 'Focus mode',
    'exitFocusMode': 'Exit focus mode',
    'searchReplace': 'Find and replace',
    'editorFontSize': 'Manuscript font size',
    'findText': 'Find',
    'replaceWith': 'Replace with',
    'matches': 'Matches',
    'nextMatch': 'Next match',
    'replaceNext': 'Replace next',
    'replaceAll': 'Replace all',
    'autosaveSaved': 'Saved',
    'autosavePending': 'Unsaved',
    'autosaveSaving': 'Saving...',
    'autosaveError': 'Save failed',
    'sceneInspector': 'Scene inspector',
    'summary': 'Summary',
    'goal': 'Goal',
    'conflict': 'Conflict',
    'outcome': 'Outcome',
    'status': 'Status',
    'wordTarget': 'Word target',
    'catalog': 'Catalog',
    'name': 'Name',
    'newCharacter': 'New Character',
    'newLocation': 'New Location',
    'newObject': 'New Object',
    'newCatalogItem': 'New Entry',
    'editCatalogItem': 'Edit entry',
    'saveCatalogItem': 'Save entry',
    'untitledCharacter': 'Untitled Character',
    'untitledLocation': 'Untitled Location',
    'untitledObject': 'Untitled Object',
    'untitledCatalogItem': 'Untitled Entry',
    'catalogItemCreated': 'Catalog item created',
    'catalogItemSaved': 'Catalog item saved',
    'noCharactersTitle': 'No characters yet',
    'noLocationsTitle': 'No locations yet',
    'noObjectsTitle': 'No objects yet',
    'noCatalogItemsTitle': 'No entries yet',
    'catalogEmptyBody':
        'Create profiles and use them as context for scenes, analysis, and AI suggestions.',
    'noSummary': 'No summary',
    'sceneContext': 'Scene context',
    'sceneContextEmpty':
        'Create characters, locations, or objects to link them with this scene.',
    'relationships': 'Relationships',
    'openSuggestions': 'Open suggestions',
    'metricEvents': 'Local events',
    'todaySaves': 'Saves today',
    'aiUses': 'AI usage',
    'recentMetrics': 'Recent local events',
    'noMetricsYet': 'No local metrics for this project yet.',
    'workspace': 'Workspace',
    'commandPalette': 'Command palette',
    'searchCommands': 'Search command, scene, or entity',
    'noCommandMatches': 'No matches.',
    'recentScenes': 'Recent scenes',
    'sceneBoard': 'Scene board',
    'relationshipGraph': 'Relationship graph',
    'statistics': 'Statistics',
    'statisticsBody': 'Metrics for the current project.',
    'inProgress': 'In progress',
    'done': 'Done',
    'lockedOrArchived': 'Locked or archived',
    'noScenesInStatus': 'No scenes in this status.',
    'chooseStatus': 'Choose status',
    'structureCockpit': 'Structure cockpit',
    'planningGaps': 'Planning gaps',
    'unassignedScenes': 'No chapter',
    'timeline': 'Timeline',
    'unscheduled': 'Unscheduled',
    'statusSpread': 'Status spread',
    'datedScenes': 'Dated scenes',
    'chapterOverview': 'Chapter overview',
    'structureInspector': 'Structure inspector',
    'authorStructureCockpit': 'Author cockpit',
    'authorStructureCockpitBody':
        'Scene flow, open conflicts, entities, and patterns in the current project.',
    'structureComplete': 'Planning complete',
    'missing': 'Missing',
    'openScene': 'Open scene',
    'noPlanningGaps': 'No open planning gaps',
    'openConflicts': 'Open conflicts',
    'noOpenConflicts': 'No open conflicts',
    'noUnscheduledScenes': 'All scenes have a date',
    'noTimelineScenes': 'No dated scenes yet',
    'timelineBody':
        'Scenes by story time. Undated scenes remain visible below.',
    'noDatedScenes': 'No dated scenes yet.',
    'undatedScenes': 'Undated scenes',
    'noUndatedScenes': 'All scenes have a date.',
    'withoutDate': 'Without date',
    'entityWeb': 'Entity web',
    'motifTracker': 'Motif tracker',
    'noMotifsYet': 'No patterns from scene type, tone, or status yet.',
    'relationshipMap': 'Relationship map',
    'noRelationshipsYet': 'No relationships linked yet.',
    'noRelationshipsTitle': 'No relationships yet',
    'noRelationshipsBody':
        'Create relationships between characters, locations, objects, or scenes.',
    'relationshipNeedsEndpoints':
        'Create at least two scenes, characters, locations, or objects first.',
    'strength': 'Strength',
    'entityDetails': 'Entity details',
    'newRelationship': 'New relationship',
    'editRelationship': 'Edit relationship',
    'deleteRelationship': 'Delete relationship',
    'deleteRelationshipBody':
        'This relationship will be removed from the project.',
    'saveRelationship': 'Save relationship',
    'relationshipSaved': 'Relationship saved',
    'relationshipDeleted': 'Relationship deleted',
    'relationshipSource': 'Source',
    'relationshipTarget': 'Target',
    'relationshipType': 'Relationship type',
    'relationshipLabel': 'Label',
    'relationshipDescription': 'Description',
    'relationshipStrength': 'Strength',
    'relationshipDirected': 'Directed',
    'relationshipUndirected': 'Bidirectional',
    'relationTypeAppearsIn': 'appears in',
    'relationTypeAlly': 'Ally',
    'relationTypeConflict': 'Conflict',
    'relationTypeFamily': 'Family',
    'relationTypeOwns': 'Owns',
    'relationTypeLocatedAt': 'Located at',
    'relationTypeForeshadows': 'Foreshadowing',
    'relationTypeCustom': 'Custom type',
    'sceneType': 'Scene type',
    'emotionalTone': 'Tone',
    'storyAnalysis': 'Storyline & Analysis',
    'storylineHealth': 'Storyline health',
    'chapterBalance': 'Chapter balance',
    'catalogPresence': 'Presence matrix',
    'openPlanningGaps': 'Open planning gaps',
    'scenesWithoutPov': 'Scenes without POV',
    'scenesWithoutDate': 'Scenes without date',
    'detachedCatalogItems': 'Entries without appearance',
    'missingStructure': 'Goal, conflict, or outcome is missing',
    'noAnalysisIssues': 'No immediate structure notes.',
    'noAppearances': 'No appearances',
    'appearances': 'Appearances',
    'linkedScenes': 'Linked scenes',
    'wordsPerChapter': 'Words per chapter',
    'structureActions': 'Structure actions',
    'moveSceneUp': 'Move scene up',
    'moveSceneDown': 'Move scene down',
    'moveToChapter': 'Move to chapter',
    'moveToNoChapter': 'No chapter',
    'aiNeedsScene': 'Create a scene before requesting AI suggestions.',
    'aiContext': 'Context',
    'aiProjectContext': 'Project',
    'aiSceneContext': 'Scene',
    'selectAiScene': 'Choose scene context',
    'aiProjectScopeHint':
        'Project-wide analysis uses title, description, chapters, and scene overview.',
    'aiPrompt': 'AI task',
    'defaultAiPrompt': 'Review this scene and suggest structuring questions.',
    'editorAiHelp': 'AI help',
    'editorAiHelpInput': 'Question or task for the current scene',
    'helpEditorAiHelp':
        'Uses the current scene context and stores the answer as an AI suggestion.',
    'sendAiHelp': 'Ask AI',
    'latestAiHelpAnswer': 'Latest answer',
    'defaultEditorAiHelpPrompt':
        'Analyze the current scene and name the most useful next decisions.',
    'requestSceneIdeas': 'Scene ideas',
    'requestStructure': 'Goal/conflict/outcome',
    'moreAiChecks': 'More checks',
    'submitAiPrompt': 'Send task',
    'aiPromptSubmitHint': 'Ctrl+Enter sends the task',
    'promptTemplates': 'Prompt templates',
    'promptPreview': 'Exact prompt sent to the LLM',
    'structuredAnswer': 'Structured answer',
    'promptTemplateSceneIdeas':
        'Develop three distinct scene variants. For each, name the conflict, new information, and narrative value.',
    'promptTemplateSceneStructure':
        'Review goal, conflict, outcome, and summary. Start with a scenePatch JSON block, then add short reasons.',
    'promptTemplateConsistency':
        'Find concrete continuity, fact, and logic issues. For each point, name the affected information and a pragmatic correction.',
    'promptTemplateTimeline':
        'Review chronology, duration, travel, and recovery time. Mark unclear spots and suggest a plausible order.',
    'promptTemplatePlotGaps':
        'Find plot gaps, missing motivation, and unclear causality. Prioritize by story risk.',
    'promptTemplateAuthorQuestions':
        'Formulate strong author questions that force decisions. No generic advice, only concrete questions about the scene.',
    'promptTemplateStyle':
        'Analyze tone, rhythm, point of view, and style effect. Give concrete levers without replacing manuscript prose.',
    'promptTemplateResearch':
        'Structure open research questions into clarify now, check later, and can be solved fictionally.',
    'promptTemplateDialogue':
        'Analyze dialogue intent, subtext, power shift, and unstated character goals.',
    'promptTemplateCharacter':
        'Review character function, goal, contradiction, and change potential in the scene context.',
    'promptTemplateStoryline':
        'Develop alternative storyline variants with consequences for conflict, pacing, and character decisions.',
    'promptTemplateBlurb':
        'Develop pitch or blurb variants without replacing final manuscript prose.',
    'aiApiKeyMissing':
        'This provider needs an API key. Save it under Settings > Provider configuration.',
    'aiRequestInProgress': 'Provider request in progress...',
    'aiRequestFailed': 'Provider request failed',
    'aiSuggestionCreated': 'AI suggestion saved',
    'aiMockProviderActive':
        'Mock / local is active - responses are demo placeholders. Save OpenRouter or another provider in Settings.',
    'aiTaskCustomScenePrompt': 'Custom AI task',
    'aiTaskCharacterProfile': 'Character profile',
    'aiTaskConsistencyCheck': 'Consistency check',
    'aiTaskTimelineCheck': 'Timeline check',
    'aiTaskStorylineVariants': 'Storyline variants',
    'aiTaskBlurbVariants': 'Blurb variants',
    'aiTaskStyleAnalysis': 'Style analysis',
    'aiTaskAuthorQuestions': 'Author questions',
    'aiTaskResearchStructuring': 'Research structuring',
    'aiTaskPlotGapReview': 'Plot gap review',
    'aiTaskDialogueIntentAnalysis': 'Dialogue intent analysis',
    'suggestions': 'Suggestions',
    'noSuggestions': 'No suggestions yet',
    'notes': 'Notes',
    'noNotes': 'No notes yet',
    'notesCockpit': 'Notes cockpit',
    'newNote': 'New note',
    'editNote': 'Edit note',
    'untitledNote': 'Untitled note',
    'noteTitle': 'Title',
    'noteBody': 'Note',
    'noteTarget': 'Target',
    'targetProject': 'Project-wide',
    'searchNotes': 'Search notes',
    'allNotes': 'All',
    'projectNotes': 'Project',
    'sceneNotes': 'Scenes',
    'catalogNotes': 'Catalog',
    'manualNotes': 'Manual',
    'aiNotes': 'AI',
    'manualNote': 'Manual note',
    'aiNote': 'AI note',
    'noNotesForFilter': 'No matching notes',
    'noNoteSelectedTitle': 'No note selected',
    'noNoteSelectedBody': 'Create a note or select an item on the left.',
    'openLinkedScene': 'Open linked scene',
    'saveNote': 'Save note',
    'noteCreated': 'Note created',
    'noteSaved': 'Note saved',
    'noteDeleted': 'Note deleted',
    'aiResponse': 'Response',
    'sentPrompt': 'Sent prompt',
    'suggestionPending': 'pending',
    'suggestionAccepted': 'accepted',
    'suggestionRejected': 'rejected',
    'suggestionConverted': 'saved as note',
    'suggestionAcceptedFeedback': 'Suggestion accepted',
    'suggestionAppliedFeedback': 'Suggestion applied to scene planning',
    'suggestionAcceptedNoPatchFeedback':
        'Suggestion accepted, no planning fields changed',
    'suggestionDeletedFeedback': 'Suggestion deleted',
    'suggestionConvertedFeedback': 'Note created from suggestion',
    'applyPreview': 'Apply preview',
    'noApplyPreview':
        'No applicable scene fields detected. Accepting only marks the suggestion as reviewed.',
    'accept': 'Accept',
    'reject': 'Reject',
    'convertToNote': 'Mark as note',
    'exportPreview': 'Export preview',
    'copyExport': 'Copy export',
    'downloadExport': 'Download export',
    'exportCopied': 'Export copied to clipboard',
    'exportDownloaded': 'Export downloaded',
    'exportCancelled': 'Export cancelled',
    'archiveExportBody':
        'Complete Writeler archive for backup, migration, or import into another Writeler instance.',
    'selfPublishingBody':
        'Readable manuscript output for sharing, editing, or publishing.',
    'publishingFormat': 'Output format',
    'downloadManuscript': 'Download manuscript',
    'includePublishingMetadata': 'Include notes and project info',
    'syncCheckpoint': 'Sync checkpoint',
    'syncCheckpointBody':
        'Creates a complete local sync package for manual storage, WebDAV, or future cloud adapters.',
    'copySyncCheckpoint': 'Copy sync checkpoint',
    'syncCheckpointCopied': 'Sync checkpoint copied to clipboard',
    'lastSyncCheckpoint': 'Last checkpoint',
    'syncFingerprint': 'Fingerprint',
    'syncPayloadSize': 'Payload size',
    'syncPayloadDetected': 'Sync package detected',
    'syncAdapter': 'Sync adapter',
    'syncAdapterHint':
        'Local use remains independent; cloud sync is only an optional adapter.',
    'importArchive': 'Import project',
    'archiveSchema': 'Archive schema',
    'chooseImportFile': 'Choose import file',
    'dropImportFile': 'Drop file here',
    'dropImportFileBody':
        'Writeler JSON, yWriter (.yw5/.yw6/.yw7), Scrivener (.scrivx), Markdown, or TXT',
    'selectedImportFile': 'Selected file',
    'importSourceType': 'Import type',
    'archivePreviewInvalid': 'Archive preview unavailable',
    'pasteArchiveJson': 'Paste JSON, yWriter XML, or text here',
    'importProject': 'Import project',
    'importComplete': 'Project archive imported',
    'helpCopyExport':
        'Copies the current export preview with the selected options to the clipboard.',
    'helpExportFormat':
        'Export creates a complete Writeler archive with all project data for later import.',
    'helpPublishingFormat':
        'Controls which readable manuscript format is used for publishing output.',
    'helpIncludeSceneTitles':
        'Adds scene titles before the matching text sections in the export.',
    'helpIncludeMetadata':
        'Includes planning data such as status, goal, conflict, and outcome in the export.',
    'helpIncludePublishingMetadata':
        'Appends project info and notes to the manuscript while keeping the readable text primary.',
    'helpDownloadExport':
        'Creates a complete Writeler archive file and saves it locally.',
    'helpDownloadManuscript':
        'Creates a readable manuscript file in the selected format and saves it locally.',
    'helpCopySyncCheckpoint':
        'Copies a complete local sync package that can be imported again later.',
    'helpImportFile':
        'Loads a file and automatically detects Writeler, yWriter, Scrivener, Markdown, or text.',
    'helpPasteImport':
        'Checks pasted content and shows a preview of the detected project before import.',
    'helpImportProject':
        'Creates a new local project from the preview, including chapters, scenes, and catalog data.',
    'format': 'Format',
    'includeSceneTitles': 'Include scene titles',
    'includeMetadata': 'Include metadata',
    'nothingToExport': 'Nothing to export yet',
    'selectProject': 'Select a project',
    'aiEnabled': 'AI assistance',
    'cloudSyncEnabled': 'Cloud sync',
    'noAiNoCloud': 'No AI / No Cloud',
    'providerConfig': 'Provider configuration',
    'providerKind': 'Provider type',
    'providerEnabled': 'Provider enabled',
    'providerName': 'Provider name',
    'modelName': 'Model name',
    'baseUrl': 'Base URL',
    'apiKeyRef': 'API key',
    'apiKeyWebWarning':
        'Stored locally in secure storage, separate from provider configuration.',
    'apiKeyStoredHint': 'API key is securely stored. Leave blank to keep it.',
    'deleteApiKey': 'Delete API key',
    'apiKeyDeleted': 'API key deleted',
    'saveProviderConfig': 'Save provider',
    'providerConfigSaved': 'Provider configuration saved',
    'helpDesignSettings':
        'Changes only the app appearance. Projects and writing content stay untouched.',
    'helpGlobalProfileSettings':
        'These options apply app-wide until future project profiles override them.',
    'helpProjectMetadata':
        'Stores details for the current project, such as the author name.',
    'helpAiEnabled':
        'Turns AI features on or off globally. Manuscript text is never changed automatically.',
    'helpCloudSyncEnabled':
        'Allows future cloud sync adapters while local work remains available.',
    'helpNoAiNoCloud':
        'Disables AI and cloud sync together for a deliberately local work mode.',
    'helpProviderKind':
        'Selects the technical interface for AI requests, such as OpenRouter, OpenAI, or Ollama.',
    'helpProviderEnabled':
        'Enables or pauses the configured AI provider without deleting saved settings.',
    'helpProviderName':
        'A display name that helps you recognize this provider later.',
    'helpModelName': 'The exact model name sent to the provider.',
    'helpBaseUrl': 'The provider API address. Presets fill this automatically.',
    'helpApiKey':
        'The key is stored locally and used for real provider requests.',
    'helpDeleteApiKey':
        'Removes only the locally stored API key. The rest of the provider configuration remains.',
    'helpSaveProviderConfig':
        'Saves provider, model, URL, enabled state, and optionally the API key for future AI requests.',
    'helpAiContext':
        'The context decides whether AI reasons about the whole project or only about the selected scene.',
    'helpPromptTemplates':
        'Fills the instruction with a useful starter prompt. You can edit the text before sending.',
    'helpSubmitAiPrompt':
        'Sends the visible instruction with the selected context to the active AI provider and stores the answer as a suggestion.',
    'helpAiQuickActions':
        'These actions immediately send specialized idea or review requests to AI.',
    'helpPromptPreview':
        'Shows the complete prompt that is actually sent to the language model.',
    'helpSuggestionActions':
        'Accept reviews and applies recognized planning fields, note creates a project note, reject deletes the suggestion.',
    'helpAcceptSuggestion':
        'Applies recognized structure fields to the scene or marks the suggestion as reviewed.',
    'helpConvertSuggestion':
        'Stores the AI answer as a note so it can be reused later.',
    'helpRejectSuggestion': 'Deletes the suggestion from the open AI list.',
    'helpNewProject':
        'Creates a new local writing project. Existing projects stay unchanged.',
    'helpNewScene':
        'Creates a new scene in the current project and opens it for editing.',
    'helpNewChapter': 'Creates a new chapter that scenes can be assigned to.',
    'helpDeleteChapter':
        'Deletes the chapter after confirmation. Assigned scenes remain in the project.',
    'helpNewCatalogItem':
        'Creates a new character, location, or object in the current catalog.',
    'helpEditCatalogItem':
        'Opens the detail view so name, status, and description can be edited.',
    'helpDeleteCatalogItem':
        'Deletes the catalog item from the project after confirmation.',
    'helpSaveCatalogItem':
        'Saves name, status, description, and extra fields of this catalog item.',
    'helpNewNote':
        'Creates a new note that can be assigned to the project, a scene, or a catalog item.',
    'helpOpenLinkedScene': 'Jumps directly to the scene this note points to.',
    'helpSaveNote':
        'Saves title, target, and content of the current note locally.',
    'helpDeleteNote': 'Deletes the selected note from the project.',
    'helpNewRelationship':
        'Creates a relationship between characters, locations, objects, or scenes.',
    'helpEditRelationship':
        'Opens the relationship so type, direction, strength, and description can be adjusted.',
    'helpDeleteRelationship':
        'Deletes only this relationship. The linked entities remain.',
    'helpSaveRelationship':
        'Saves source, target, type, direction, strength, and description of this relationship.',
    'helpDeletePermanently':
        'Confirms the deletion permanently. This action cannot be undone automatically.',
    'helpStructureActions':
        'Opens actions for this scene: move, change chapter, or delete.',
    'activeProvider': 'Active provider',
    'providerNameFallback': 'Local Provider',
    'modelNameFallback': 'mock-structure-v1',
  };

  String t(String key) {
    final table =
        _dictionaries[languageCode] ?? _dictionaries[fallbackLanguageCode]!;
    return table[key] ?? _en[key] ?? key;
  }

  static const Map<String, Map<String, String>> _dictionaries = {
    'de': _de,
    'en': _en,
  };
}
