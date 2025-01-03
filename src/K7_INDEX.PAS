Program K7_Index;
{
Auteur: Pr‚martin Patrick.
Date: 09/05/1991. (v1.0)
      10/05/1991.
      11/05/1991.
      19/05/1991. (v1.1)

But: Gestion d'une liste de K7 vid‚o.
     Plusieurs donn‚es sont demand‚es … chaque fois:
          - code de la K7 (sur 3 caractŠres).
          - titre du film (sur 45 caractŠres).
          - dur‚e du film (sur 3 caractŠres).


Masque de saisie utilis‚ par l'unit‚ U_MASQ:
                 1,1,F,Code de la cassette:
                 1,2,F,Titre du film:
                 1,3,F,Dur‚e:
                 12,3,F,mn
                 22,1,V,C,3
                 16,2,V,C,45
                 8,3,V,C,3
}
{
*******************************************************************************
          DECLARATIONS DIVERSES
*******************************************************************************
}
Uses Crt,
     olf_software,
     U_Fenetre,
     U_Sgf,
     U_Code_Clavier,
     U_Curseur,
     U_Chaine,
     U_Selection,
     U_Masq,
     U_Aff_Chaine,
     U_Ger_Chaine,
     U_Util;

Const
     Num_Version  : String [3]  = '1.1';
      Date_Version : String [10] = '19/05/1991';
      Hv                         = #255;
      Nb_Max_Films               = 1000;
      Lg_Code                    = 3;
      Lg_Titre                   = 45;
      Lg_Duree                   = 3;
      Champ_Code                 = 'Code K7';
      Champ_Titre                = 'Titre';
      Champ_Duree                = 'Duree';
      Nb_Ligne_Ecran             = 15;
      Nom_Fich_Msq               = 'K7_INDEX'; {.MSQ}
      Extension_Index            = '.K7';

Type T_Code          = String [Lg_Code];
     T_Titre         = String [Lg_Titre];
     T_Duree         = String [Lg_Duree];
     T_Vecteur_Code  = Array [1..Nb_Max_Films] Of T_Code;
     T_Vecteur_Titre = Array [1..Nb_Max_Films] Of T_Titre;
     T_Vecteur_Duree = Array [1..Nb_Max_Films] Of T_Duree;
     T_Enreg         = Record
                         Code  : T_Code;
                         Titre : T_Titre;
                         Duree : T_Duree
                       End;
     T_File_Enreg    = File Of T_Enreg;
     T_Nom_Fich      = Chaine20;

Var Masque_Saisie  : Masque;
    Vecteur_Code   : T_Vecteur_Code;
    Vecteur_Titre  : T_Vecteur_Titre;
    Vecteur_Duree  : T_Vecteur_Duree;
    Nb_Films       : Integer;
    Nom_Fichier    : T_Nom_Fich;
    Lg_Champ_Code,
    Lg_Champ_Titre,
    Lg_Champ_Duree : Integer;
    Num_Haut,
    Position       : Integer;

{
*******************************************************************************
          GESTION DES ENREGISTREMETS
*******************************************************************************
}
Procedure Set_Code (Code : T_Code; Var Enreg : T_Enreg);
Begin { set_code }
  Enreg.Code := Code
End; { set_code }

Function Get_Code (Enreg : T_Enreg) : T_Code;
Begin { get_code }
  Get_Code := Enreg.Code
End; { get_code }

Procedure Set_Titre (Titre : T_Titre; Var Enreg : T_Enreg);
Begin { set_titre }
  Enreg.Titre := Titre
End; { set_titre }

Function Get_Titre (Enreg : T_Enreg) : T_Titre;
Begin { get_titre }
  Get_Titre := Enreg.Titre
End; { get_titre }

Procedure Set_Duree (Duree : T_Duree; Var Enreg : T_Enreg);
Begin { set_duree }
  Enreg.Duree := Duree
End; { set_duree }

Function Get_Duree (Enreg : T_Enreg) : T_Duree;
Begin { get_duree }
  Get_Duree := Enreg.Duree
End; { get_duree }

{
*******************************************************************************
          PROCEDURES DIVERSES DE TRANSFERT ENTRE LES TYPES DE DONNEES
*******************************************************************************
}
Procedure Transfert_Masque_Tampon (Masq : Masque; Var Enreg : T_Enreg);
Begin { transfert_masque_tampon }
  Set_Code (Cadrer_Droite (Masq.Zone [5].Valeur), Enreg);
  Set_Titre (Cadrer_Gauche (Masq.Zone [6].Valeur), Enreg);
  Set_Duree (Cadrer_Droite (Masq.Zone [7].Valeur), Enreg)
End; { transfert_masque_tampon }

Procedure Transfert_Tampon_Element (Enreg : T_Enreg; Num_Elem : Integer);
Begin { transfert_tampon_element }
  Vecteur_Code [Num_Elem] := Get_Code (Enreg);
  Vecteur_Titre [Num_Elem] := Get_Titre (Enreg);
  Vecteur_Duree [Num_Elem] := Get_Duree (Enreg)
End; { transfert_tampon_element }

Procedure Transfert_Element_Masque (Num_Elem : Integer; Var Masq : Masque);
Begin { transfert_element_masque }
  Masq.Zone [5].Valeur := Vecteur_Code [Num_Elem];
  Masq.Zone [6].Valeur := Vecteur_Titre [Num_Elem];
  Masq.Zone [7].Valeur := Vecteur_Duree [Num_Elem]
End; { transfert_element_masque }

Procedure Transfert_Masque_Element (Masq : Masque; Num_Elem : Integer);
Begin { transfert_masque_element }
  Vecteur_Code  [Num_Elem] := Cadrer_Droite (Masq.Zone [5].Valeur);
  Vecteur_Titre [Num_Elem] := Cadrer_Gauche (Masq.Zone [6].Valeur);
  Vecteur_Duree [Num_Elem] := Cadrer_Droite (Masq.Zone [7].Valeur)
End; { transfert_masque_element }

Procedure Transfert_Element_Tampon (Num_Elem : Integer; Var Enreg : T_Enreg);
Begin { transfert_element_tampon }
  Set_Code (Vecteur_Code [Num_Elem], Enreg);
  Set_Titre (Vecteur_Titre [Num_Elem], Enreg);
  Set_Duree (Vecteur_Duree [Num_Elem], Enreg)
End; { transfert_element_tampon }

Procedure Transfert_Tampon_Masque (Enreg : T_Enreg; Var Masq : Masque);
Begin { transfert_tampon_masque }
  Masq.Zone [5].Valeur := Get_Code (Enreg);
  Masq.Zone [6].Valeur := Get_Titre (Enreg);
  Masq.Zone [7].Valeur := Get_Duree (Enreg)
End; { transfert_tampon_masque }

{
*******************************************************************************
          PROCEDURES ET FONCTIONS DIVERSES
*******************************************************************************
}
Procedure Met_Sentinelle (Num_Elem : Integer);
Begin { met_sentinelle }
  Vecteur_Code [Num_Elem] := Hv;
  Vecteur_Titre [Num_Elem] := Hv;
  Vecteur_Duree [Num_Elem] := Hv
End; { met_sentinelle }

Procedure Null;
Begin { null }
End; { null }

Function Max (A, B : Integer) : Integer;
Begin { max }
  If (A > B)
  Then
    Max := A
  Else
    Max := B
  {endif}
End; { max }

Function Min (A, B : Integer) : Integer;
Begin { min }
  If (A < B)
  Then
    Min := A
  Else
    Min := B
  {endif}
End; { max }

Procedure Ecrit_Centre (Message : String; Longueur_Champ : Integer);
Var Chaine : String;
    I      : Integer;
    J : Integer;
Begin { ecrit_centre }
  Chaine := '';
  For I := 1 To Longueur_Champ Do
    Chaine := Concat (Chaine, ' ')
  {endfor};
  Copie_Milieu (Message, Chaine);
  Write (Chaine)
End; { ecrit_centre }

Procedure Son_Cloche;
Var I : Integer;
Begin { son_cloche }
  For I := 1 To 255 Do
    Sound (I)
  {endfor};
  For I := 255 Downto 1 Do
    Sound (I)
  {endfor};
  Nosound
End; { son_cloche }

{
*******************************************************************************
          GESTION DES ERREURS D'ENTREE/SORTIE
*******************************************************************************
}
Function Io_Erreur (Nom_Fichier : T_Nom_Fich; In_Out : Boolean) : Boolean;
Var Result : Integer;
Begin { io_erreur }
  {$i+}
  Result := Ioresult;
  Case Result Of
    0 : Null
  Else
    Write ('AccŠs au fichier ', Nom_Fichier, ' impossible ');
    If (In_Out)
    Then
      Writeln ('en ‚criture...')
    Else
      Writeln ('en lecture...')
    {endif};
    Writeln ('Veuillez v‚rifier, puis appuyez sur une touche.');
    Vidange_Tampon_Clavier;
    Repeat
    Until Keypressed;
    Vidange_Tampon_Clavier
  End;
  Io_Erreur := (Result <> 0)
End; { io_erreur }

{
*******************************************************************************
          PROCEDURES D'ACCES AUX FICHIERS
*******************************************************************************
}
Procedure Charge_Liste (Nom_Fichier : T_Nom_Fich);
Var Fichier : T_File_Enreg;
    Enreg   : T_Enreg;
Begin { charge_liste }
  Nb_Films := 0;
  Nom_Fichier := Concat (Nom_Fichier, Extension_Index);
  If Exist (Nom_Fichier)
  Then
    Begin
      Assign (Fichier, Nom_Fichier);
      Repeat
        {$i-}
        Reset (Fichier)
        {$i+}
      Until (Not Io_Erreur (Nom_Fichier, False));
      While Not (Eof (Fichier) Or (Nb_Films = Nb_Max_Films - 1)) Do
        Begin
          Inc (Nb_Films);
          Read (Fichier, Enreg);
          Transfert_Tampon_Element (Enreg, Nb_Films)
        End
      {endwhile};
      Close (Fichier)
    End
  {endif};
  Met_Sentinelle (Succ (Nb_Films))
End; { charge_liste }

Procedure Sauve_Liste (Nom_Fichier : T_Nom_Fich);
Var Fichier : T_File_Enreg;
    Enreg   : T_Enreg;
    I       : Integer;
Begin { sauve_liste }
  Nom_Fichier := Concat (Nom_Fichier, Extension_Index);
  Assign (Fichier, Nom_Fichier);
  Repeat
    {$i-}
    Rewrite (Fichier)
    {$i+}
  Until (Not Io_Erreur (Nom_Fichier, True));
  For I := 1 To Nb_Films Do
    Begin
      Transfert_Element_Tampon (I, Enreg);
      Write (Fichier, Enreg)
    End
  {endfor};
  Close (Fichier)
End; { sauve_liste }

Procedure Sauve_Ascii (Nom_Fichier : T_Nom_Fich);
Var Fichier : Text;
    I       : Integer;
Begin { sauve_ascii }
  Nom_Fichier := Concat (Nom_Fichier, '.LST');
  Assign (Fichier, Nom_Fichier);
  Repeat
    {$i-}
    Rewrite (Fichier)
    {$i+}
  Until (Not Io_Erreur (Nom_Fichier, True));
  For I := 1 To Nb_Films Do
    Writeln (Fichier, Vecteur_Code [I] : Succ (Lg_Code),
                      Vecteur_Titre [I] : Succ (Lg_Titre),
                      Vecteur_Duree [I] : Succ (Lg_Duree))
  {endfor};
  Close (Fichier)
End; { sauve_ascii }

{
*******************************************************************************
          OPERATIONS A FAIRE EN DEBUT ET FIN DE SESSION
*******************************************************************************
}
Procedure Debut_Session;
Begin { debut_session }
  If (Paramcount > 0)
  Then
    Begin
      Nom_Fichier := Get_Nom_Fichier (Paramstr (1));
      If (Pos ('.', Nom_Fichier) > 0)
      Then
        Nom_Fichier := Copy (Nom_Fichier, 1, Pred (Pos ('.', Nom_Fichier)))
      {endif}
    End
  Else
    Nom_Fichier := ''
  {endif};
  If (Nom_Fichier = '')
  Then
    Nom_Fichier := 'K7_INDEX'
  {endif};
  Charge_Liste (Nom_Fichier);
  Lire_Masque (Masque_Saisie, Nom_Fich_Msq);
  Lg_Champ_Code := Max (Lg_Code, Length (Champ_Code));
  Lg_Champ_Titre := Max (Lg_Titre, Length (Champ_Titre));
  Lg_Champ_Duree := Max (Lg_Duree, Length (Champ_Duree))
End; { debut_session }

Procedure Fin_Session;
Begin { fin_session }
  Sauve_Liste (Nom_Fichier)
End; { fin_session }

{
*******************************************************************************
          PRESENTATION ET ECRAN D'INFORMATIONS
*******************************************************************************
}
Procedure Presentation;
Begin { presentation }
  Clrscr;
  Type_Cadre := 6;
  Window_Cadre_Bis (2, 2, 79, 9, Lightgray, Black);
  Window_Titre ('K7 INDEX', Black, Lightgray);
  Video_Clignotante;
  Affic_Center_Ln ('de Pr‚martin Patrick');
  Affic_Center_Ln (Concat ('Version ', Num_Version, ' dat‚e du ', Date_Version, '.'));
  Video_Normale;
  Writeln;
  Writeln ('   Ce programme permet de faire une liste de K7 vid‚o, de la consulter tri‚e');
  Writeln ('par titre, par code (de la cassette), ou par dur‚e, mais aussi de la sauver');
  Writeln ('au format ASCII afin de pouvoir l''utiliser avec d''autres utilitaires.');
  Writeln;
  Attente_Appuit_Touche;
  Clear_Window
End; { presentation }

Procedure Information;
Begin { information }
  Clrscr;
  Type_Cadre := 7;
  Window_Cadre_Bis (2, 2, 79, 18, Lightgray, Black);
  Window_Titre ('K7 INDEX', Black, Lightgray);
  Video_Clignotante;
  Affic_Center_Ln ('ECRAN D''AIDE');
  Video_Normale;
  Writeln;
  Writeln ('Liste des commandes accessibles:');
  Writeln ('     - F1  affiche cet ‚cran d''aide.');
  Writeln ('     - F10 quitte le programme aprŠs sauvegarde des modifications.');
  Writeln ('     - ESC quitte le programme aprŠs sauvegarde des modifications.');
  Writeln ('     - I   insere un film dans la liste.');
  Writeln ('     - L   sauve la liste au format ASCII.');
  Writeln ('     - M   modifie le film en inversion video.');
  Writeln ('     - Q   quitte le programme aprŠs sauvegarde des modifications.');
  Writeln ('     - S   suppression du film en inversion video.');
  Writeln ('     - T   tri de la liste aprŠs choix du champ … regarder.');
  Writeln;
  Writeln ('   Les d‚placements dans la liste des films se fait … l''aide des flŠches, de');
  Writeln ('HOME, END, PgUp, et PgDn.');
  Writeln;
  Attente_Appuit_Touche;
  Clear_Window
End; { information }

{
*******************************************************************************
          AFFICHAGE DE LA LISTE
*******************************************************************************
}
Procedure Ligne_Haut;
Var I : Integer;
Begin { ligne_haut }
  Write ('Ö'); { #214 }
  For I := 1 To Lg_Champ_Code Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('Ò'); { #210 }
  For I := 1 To Lg_Champ_Titre Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('Ò'); { #210 }
  For I := 1 To Lg_Champ_Duree Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('·'); { #183 }
  Writeln
End; { ligne_haut }

Procedure Ligne_Titre;
Begin { ligne_haut }
  Write ('º'); { #186 }
  Ecrit_Centre (Champ_Code, Lg_Champ_Code);
  Write ('º'); { #186 }
  Ecrit_Centre (Champ_Titre, Lg_Champ_Titre);
  Write ('º'); { #186 }
  Ecrit_Centre (Champ_Duree, Lg_Champ_Duree);
  Write ('º'); { #186 }
  Writeln
End; { ligne_titre }

Procedure Ligne_Bas;
Var I : Integer;
Begin { ligne_bas }
  Write ('Ç'); { #199 }
  For I := 1 To Lg_Champ_Code Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('×'); { #215 }
  For I := 1 To Lg_Champ_Titre Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('×'); { #215 }
  For I := 1 To Lg_Champ_Duree Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('¶'); { #182 }
  Writeln
End; { ligne_bas }

Procedure Affiche_Haut;
Begin { affiche_haut }
  Video_Normale;
  Ligne_Haut;
  Ligne_Titre;
  Ligne_Bas
End; { affiche_haut }

Procedure Affiche_Element (Numero : Integer);
Var Chaine : String;
Begin { affiche_element }
  Write ('º'); { #186 }
  Chaine := Vecteur_Code [Numero];
  Complementer_Chaine (Chaine, Lg_Champ_Code);
  Write (Chaine);
  Write ('º'); { #186 }
  Chaine := Vecteur_Titre [Numero];
  Complementer_Chaine (Chaine, Lg_Champ_Titre);
  Write (Chaine);
  Write ('º'); { #186 }
  Chaine := Vecteur_Duree [Numero];
  Complementer_Chaine (Chaine, Lg_Champ_Duree);
  Write (Chaine);
  Write ('º'); { #186 }
  Writeln
End; { affiche_element }

Procedure Affiche_Bas;
Var I : Integer;
Begin { affiche_bas }
  Write ('Ó'); { #211 }
  For I := 1 To Lg_Champ_Code Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('Ð'); { #208 }
  For I := 1 To Lg_Champ_Titre Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('Ð'); { #208 }
  For I := 1 To Lg_Champ_Duree Do
    Write ('Ä') { #196 }
  {endfor};
  Write ('½'); { #189 }
  Writeln
End; { affiche_bas }

Procedure Ligne_Menu;
Begin { ligne_menu }
  Inverse_Video;
  Affic_Center_Ln ('I-Insertion, L-Liste ASCII, M-Modification, Q-Quitter, S-Suppression, T-Tri');
  Affic_Center_Ln ('F1-Aide F10-Quitter');
  Affic_Center_Ln ('ESCape-Quitter');
  Video_Normale
End; { ligne_menu }

Procedure Affichage_Ecran (Num_Haut, Position : Integer);
Var I : Integer;
Begin { affichage_ecran }
  Clrscr;
  Affiche_Haut;
  I := Num_Haut;
  While Not ((I > Nb_Films) Or (I - Num_Haut = Nb_Ligne_Ecran)) Do
    Begin
      If (I = Position)
      Then
        Begin
          Inverse_Video;
          Affiche_Element (I);
          Video_Normale
        End
      Else
        Affiche_Element (I)
      {endif};
      Inc (I)
    End
  {endwhile};
  While Not (I - Num_Haut = Nb_Ligne_Ecran) Do
    Begin
      Affiche_Element (Succ (Nb_Films));
      Inc (I)
    End
  {endwhile};
  Affiche_Bas;
  Ligne_Menu
End; { affichage_ecran }

{
*******************************************************************************
          OPERATIONS DIVERSES SUR LA LISTE
*******************************************************************************
}
Procedure Insertion_Element;
Var Raz,
    Abandon,
    Validation : Boolean;
    Enreg1,
    Enreg2     : T_Enreg;
    I          : Integer;
Begin { insertion_element }
  Clrscr;
  If (Succ (Nb_Films) < Nb_Max_Films)
  Then
    Begin
      Type_Cadre := 6;
      Window_Cadre_Bis (2, 2, 79, 5, Black, Lightgray);
      Window_Titre ('Insertion d''un film.', Lightgray, Black);
      Video_Normale;
      Clrscr;
      Curseur_On;
      Raz := True;
      Saisir_Masque (Masque_Saisie, Raz, Abandon);
      Clear_Window;
      Transfert_Masque_Element (Masque_Saisie, Succ (Nb_Films));
      Validation := Not (Abandon
         Or (Justifier_Droite (Vecteur_Code [Succ (Nb_Films)]) = Chaine_Vide)
         Or (Justifier_Droite (Vecteur_Titre [Succ (Nb_Films)]) = Chaine_Vide)
         Or (Justifier_Droite (Vecteur_Duree [Succ (Nb_Films)]) = Chaine_Vide));
      If Validation
      Then
        Begin
          I := 1;
          While (Validation And Not (I > Nb_Films)) Do
            Begin
              Validation := (
                       (Vecteur_Code [I] <> Vecteur_Code [Succ (Nb_Films)])
                    Or (Vecteur_Titre [I] <> Vecteur_Titre [Succ (Nb_Films)])
                    Or (Vecteur_Duree [I] <> Vecteur_Duree [Succ (Nb_Films)]));
              Inc (I)
            End
          {endwhile};
          If (Validation)
          Then
            Begin
              Inc (Nb_Films);
              Met_Sentinelle (Succ (Nb_Films))
            End
          Else
            Message_Alerte ('Vous avez d‚j… ins‚r‚ ces donn‚es...', True)
          {endif}
        End
      Else
        Begin
          Message_Alerte ('Insertion refus‚e...', True);
          Met_Sentinelle (Succ (Nb_Films))
        End
      {endif}
    End
  Else
    Begin
      Message_Alerte ('Vous ne pouvez plus rajouter de films...', True);
      Son_Cloche
    End
  {endif};
  Curseur_Off
End; { insertion_element }

Procedure Modification_Element (Num_Elem : Integer);
Var Enreg      : T_Enreg;
    I          : Integer;
    Raz,
    Abandon,
    Validation : Boolean;
Begin { modification_element }
  If (Nb_Films > 0)
  Then
    Begin
      Clrscr;
      Type_Cadre := 6;
      Window_Cadre_Bis (2, 2, 79, 5, Black, Lightgray);
      Window_Titre ('Modification d''un film.', Lightgray, Black);
      Video_Normale;
      Clrscr;
      Transfert_Element_Tampon (Num_Elem, Enreg);
      Transfert_Element_Masque (Num_Elem, Masque_Saisie);
      Curseur_On;
      Raz := False;
      Saisir_Masque (Masque_Saisie, Raz, Abandon);
      Clear_Window;
      Transfert_Masque_Element (Masque_Saisie, Num_Elem);
      Validation := Not (Abandon
             Or (Justifier_Droite (Vecteur_Code [Num_Elem]) = Chaine_Vide)
             Or (Justifier_Droite (Vecteur_Titre [Num_Elem]) = Chaine_Vide)
             Or (Justifier_Droite (Vecteur_Duree [Num_Elem]) = Chaine_Vide));
      If Validation
      Then
        Begin
          I := 1;
          While (Validation And Not (I > Nb_Films)) Do
            Begin
              Validation := (
                      (Vecteur_Code [I] <> Vecteur_Code [Num_Elem])
                   Or (Vecteur_Titre [I] <> Vecteur_Titre [Num_Elem])
                   Or (Vecteur_Duree [I] <> Vecteur_Duree [Num_Elem])
                   Or (I = Num_Elem));
              Inc (I)
            End
          {endwhile};
          If (Not Validation)
          Then
            Begin
              Message_Alerte ('Ce film existe d‚j…...', True);
              Transfert_Tampon_Element (Enreg, Num_Elem)
            End
          {endif}
        End
      Else
        Begin
          Message_Alerte ('Modification refus‚e...', True);
          Transfert_Tampon_Element (Enreg, Num_Elem)
        End
      {endif};
      Curseur_Off
    End
  Else
    Son_Cloche
  {endif}
End; { modification_element }

Procedure Suppression_Element (Num_Elem : Integer);
Var Enreg : T_Enreg;
    I     : Integer;
Begin { suppression_element }
  If (Nb_Films > 0)
  Then
    Begin
      Clrscr;
      Type_Cadre := 6;
      Window_Cadre_Bis (2, 2, 79, 5, Black, Lightgray);
      Window_Titre ('Suppression d''un film.', Lightgray, Black);
      Video_Normale;
      Clrscr;
      Transfert_Element_Masque (Num_Elem, Masque_Saisie);
      Affiche_Masque (Masque_Saisie, False);
      I := 1;
      Repeat
        Gotoxy (1, Succ (I));
        Inc (I)
      Until (I > Wherey);
      If (Oui ('Supprimer ce film ? (O/N) '))
      Then
        Begin
          For I := Num_Elem To Nb_Films Do
            Begin
              Transfert_Element_Tampon (Succ (I), Enreg);
              Transfert_Tampon_Element (Enreg, I)
            End
          {endfor};
          Met_Sentinelle (Nb_Films);
          Dec (Nb_Films);
          Position := Min (Nb_Films, Position)
        End
      {endif};
      Clear_Window;
      Curseur_Off
    End
  Else
    Son_Cloche
  {endif}
End; { suppression_element }

Procedure Tri;
Var Valeur : Integer;
    Enreg1,
    Enreg2 : T_Enreg;

  Procedure Trier_Liste (Champ, L, R : Integer);
  { Algorithme de QuickSort. }
  Var I,
      J : Integer;
      X : String;
  Begin { trier_liste }
    I := L;
    J := R;
    Case Champ Of
      1 : X := Vecteur_Code [(L+R) Div 2];
      2 : X := Vecteur_Titre [(L+R) Div 2];
      3 : X := Vecteur_Duree [(L+R) Div 2]
    End;
    Repeat
      While (((Vecteur_Code [I] < X) And (Champ = 1)) Or
             ((Vecteur_Titre [I] < X) And (Champ = 2)) Or
             ((Vecteur_Duree [I] < X) And (Champ = 3))) Do
        Inc (I)
      {endwhile};
      While (((X < Vecteur_Code [J]) And (Champ = 1)) Or
             ((X < Vecteur_Titre [J]) And (Champ = 2)) Or
             ((X < Vecteur_Duree [J]) And (Champ = 3))) Do
        Dec (J)
      {endwhile};
      If (I <= J)
      Then
        Begin
          Transfert_Element_Tampon (I, Enreg1);
          Transfert_Element_Tampon (J, Enreg2);
          Transfert_Tampon_Element (Enreg1, J);
          Transfert_Tampon_Element (Enreg2, I);
          Inc (I);
          Dec (J)
        End
      {endif}
    Until (I > J);
    If (L < J)
    Then
      Trier_Liste (Champ, L, J)
    {endif};
    If (I < R)
    Then
      Trier_Liste (Champ, I, R)
    {endif}
  End; { trier_liste }

Begin { tri }
  Clrscr;
  Valeur := 0;
  Valeur := Changer_Valeur ('0-Pas de tri, 1-Tri par codes, 2-Tri par titres, 3-Tri par dur‚es.', 0, 3, Valeur);
  Case Valeur Of
    1..3 : Begin
             Message_Alerte ('Tri en cours, veuillez patienter...', False);
             Trier_Liste (Valeur, 1, Nb_Films);
             Clear_Window
           End
  Else
    Son_Cloche
  End
End; { tri }

{
*******************************************************************************
          TRAITEMENT DES OPTIONS DU MENU
*******************************************************************************
}
Procedure Traitement_Deplacements (Carac : Char; Var Sortie : Boolean);
Begin { traitement_deplacements }
  Case Carac Of
    Touche_Haut : Begin
                    If (Position > 1)
                    Then
                      Begin
                        Dec (Position);
                        Gotoxy (1, Succ (Succ (Position - Num_Haut) + 3));
                        Affiche_Element (Succ (Position));
                        If (Num_Haut > Position)
                        Then
                          Begin
                            Gotoxy (1, Nb_Ligne_Ecran + 3);
                            Delline;
                            Gotoxy (1, 4);
                            Insline;
                            Dec (Num_Haut);
                          End
                        {endif};
                        Gotoxy (1, Succ (Position - Num_Haut) + 3);
                        Inverse_Video;
                        Affiche_Element (Position);
                        Video_Normale
                      End
                    {endif}
                  End;
    Touche_Bas : Begin
                   If (Position < Nb_Films)
                   Then
                     Begin
                       Inc (Position);
                       Gotoxy (1, Position - Num_Haut + 3);
                       Affiche_Element (Pred (Position));
                       If (Succ (Position - Num_Haut) > Nb_Ligne_Ecran)
                       Then
                         Begin
                           Gotoxy (1, 4);
                           Delline;
                           Gotoxy (1, Nb_Ligne_Ecran + 3);
                           Insline;
                           Inc (Num_Haut)
                         End
                       {endif};
                       Gotoxy (1, Succ (Position - Num_Haut) + 3);
                       Inverse_Video;
                       Affiche_Element (Position);
                       Video_Normale
                     End
                   {endif}
                 End;
    Touche_Home : Begin
                    Num_Haut := 1;
                    Position := 1;
                    Affichage_Ecran (Num_Haut, Position)
                  End;
    Touche_End : Begin
                   Num_Haut := Max (1, Succ (Nb_Films - Nb_Ligne_Ecran));
                   Position := Nb_Films;
                   Affichage_Ecran (Num_Haut, Position)
                 End;
    Touche_Page_Up : Begin
                       If (Position - Nb_Ligne_Ecran > 0)
                       Then
                         Begin
                           Position := Position - Nb_Ligne_Ecran;
                           Num_Haut := Max (1, Num_Haut - Nb_Ligne_Ecran);
                           Affichage_Ecran (Num_Haut, Position)
                         End
                       {endif}
                     End;
    Touche_Page_Dn : Begin
                       If (Position + Nb_Ligne_Ecran < Succ (Nb_Films))
                       Then
                         Begin
                           Position := Position + Nb_Ligne_Ecran;
                           Num_Haut := Num_Haut + Nb_Ligne_Ecran;
                           Affichage_Ecran (Num_Haut, Position)
                         End
                       {endif}
                     End
  Else
    Son_Cloche
  End
End; { traitement_deplacements }

Procedure Traitement_Fonctions (Carac : Char; Var Sortie : Boolean);
Begin { traitement_fonctions }
  Case Carac Of
    Touche_F1  : Begin
                   Information;
                   Affichage_Ecran (Num_Haut, Position)
                 End;
    Touche_F9 : Begin
                  Message_Alerte (Concat ('Sauvegarde du fichier: ', Nom_Fichier, Extension_Index), False);
                  Sauve_Liste (Nom_Fichier);
                  Clear_Window;
                  Affichage_Ecran (Num_Haut, Position)
                End;
    Touche_F10 : Sortie := True
  Else
    Son_Cloche
  End
End; { traitement_fonctions }

Procedure Traitement_Touches (Carac : Char; Var Sortie : Boolean);
Begin { traitement_touches }
  Case Upcase (Carac) Of
    'I' : Begin
            Position := Max (1, Position);
            Insertion_Element;
            Affichage_Ecran (Num_Haut, Position)
          End;
    'L' : Begin
            Message_Alerte (Concat ('Sauvegarde du fichier: ', Nom_Fichier, '.LST'), False);
            Sauve_Ascii (Nom_Fichier);
            Clear_Window;
            Affichage_Ecran (Num_Haut, Position)
          End;
    'M' : Begin
            Modification_Element (Position);
            Affichage_Ecran (Num_Haut, Position)
          End;
    'Q' : Sortie := True;
    'S' : Begin
            Suppression_Element (Position);
            Position := Min (Position, Nb_Films);
            Affichage_Ecran (Num_Haut, Position)
          End;
    'T' : Begin
            Tri;
            Affichage_Ecran (Num_Haut, Position)
          End;
    ' ' : Begin
            Message_Alerte (Concat ('Sauvegarde du fichier: ', Nom_Fichier, Extension_Index), False);
            Sauve_Liste (Nom_Fichier);
            Clear_Window;
            Affichage_Ecran (Num_Haut, Position)
          End;
    Touche_Escape : Sortie := True;
    Touche_Return : Begin
                      Modification_Element (Position);
                      Affichage_Ecran (Num_Haut, Position)
                    End
  Else
    Son_Cloche
  End
End; { traitement_touches }

Procedure Traitement;
Var Sortie : Boolean;
    Carac  : Char;
Begin { traitement }
  Sortie := False;
  Num_Haut := 1;
  Position := 1;
  Vidange_Tampon_Clavier;
  Affichage_Ecran (Num_Haut, Position);
  Repeat
    Carac := Readkey;
    If (Carac = Carac_Nul)
    Then
      Begin
        Carac := Readkey;
        Case Carac Of
          Touche_Haut,
          Touche_Bas,
          Touche_Page_Up,
          Touche_Page_Dn,
          Touche_Home,
          Touche_End            : Traitement_Deplacements (Carac, Sortie);
          Touche_F1..Touche_F10 : Traitement_Fonctions (Carac, Sortie);
        Else
          Son_Cloche
        End
      End
    Else
      Traitement_Touches (Carac, Sortie)
    {endif}
  Until Sortie
End; { traitement }

{
*******************************************************************************
          CORPS DU PROGRAMME
*******************************************************************************
}
Begin { k7_index }
      init_licence ('index');
      init_olf_message (mess_freeware);
      init_olf_software ('K7 Index '+num_version, '(c) Patrick Pr‚martin '+date_version);
  Curseur_Off;
  Reset_Screen;
  Video_Normale;
  Debut_Session;
  Presentation;
  Traitement;
  Fin_Session;
  Curseur_On;
  Reset_Screen
End. { k7_index }
