//
//  Verb.swift
//  Conjugador
//
//  Created by Jason Goldfine-Middleton on 3/13/15.
//  Copyright (c) 2015 Jason Goldfine-Middleton. All rights reserved.
//

import Foundation

/* This struct stores a valid Portuguese verb's infinitive and stem forms.
   BP = Brazilian Portuguese, EP = European Portuguese, AO = Acordo Ortográfico */
struct Verb {
  
  // Note: all member variables must be initialized before calling methods
  
  /* Store nil to indicate invalid infinitive form */
  var infinitive: String! = ""
  
  /* Last two letters in infinitive e.g. "ar", "er", "ir", "or" */
  var ending: String! = ""
  
  /* Four infinitive forms: BP post AO, BP pre AO, EP post AO, EP pre AO */
  var infinitiveVariants = [String](count: Variant.count(), repeatedValue: "")
  
  /* Four verb stem forms: BP post AO, BP pre AO, EP post AO, EP pre AO */
  var stemVariants = [String](count: Variant.count(), repeatedValue: "")
  
  /* true if verb like "dar" */
  var darDerivative: Bool {
    switch infinitive {
    case "desdar", "redar": return true
    default: return false
    }
  }
  
  /* true if verb like "estar" */
  var estarDerivative: Bool {
    switch infinitive {
    case "sobestar", "sobre-estar", "sobreestar", "sobrestar": return true
    default: return false
    }
  }
  
  /* true if verb like "ler" */
  var lerDerivative: Bool {
    switch infinitive {
    case "reler", "treler", "tresler": return true
    default: return false
    }
  }
  
  /* true if verb like "ter" */
  var terDerivative: Bool {
    switch infinitive {
    case "abster", "ater", "conter", "deter", "entreter", "manter", "obter", "reter", "suster": return true
    default: return false
    }
  }
  
  /* true if verb like "ver" */
  var verDerivative: Bool {
    switch infinitive {
    case "antever", "circunver", "entrever", "interver", "prever", "prover", "rever", "telever": return true
    default: return false
    }
  }
  
  /* true if verb like "vir" */
  var virDerivative: Bool {
    switch infinitive {
    case "advir", "avir", "contravir", "convir", "desavir", "desconvir", "devir", "entrevir", "intervir", "obvir", "provir", "reavir", "reconvir", "revir", "sobrevir", "subvir": return true
    default: return false
    }
  }
  
  /* true if verb known to be conjugated only in third person singular */
  var thirdPersonSingularOnly: Bool {
    switch infinitive {
    case "borraçar", "carujar", "chuvinhar", "merujar", "relampar", "trovejar": return true
    default: return false
    }
  }
  
  /* true if verb known to be conjugated only in third person singular and plural */
  var thirdPersonBothOnly: Bool {
    switch infinitive {
    case "aprazer", "aulir", "concernir", "condoer", "desaprazer", "doer", "grassitar", "later", "prazer", "precludir", "precluir", "reaprazer", "zinir", "zornar": return true
    default: return false
    }
  }
  
  /* true if verb has arrhizotonic forms conjugated only, i.e. "nós" and "vós" persons */
  var arrhizotonicFormsOnly: Bool {
    switch infinitive {
    case "adir", "aducir", "aguerrir", "combalir", "condir", "desempedernir", "desflorir", "desgornir", "despavorir", "desprecaver", "embair", "empedernir", "enfortir", "entalir", "esbaforir", "escarnir", "espavorir", "estransir", "estresir", "exinanir", "exir", "falir", "florir", "fornir", "fretenir", "garnir", "garrir", "gornir", "gualdir", "guarnir", "inanir", "lenir", "manutenir", "moquir", "pertransir", "precaver", "reaver", "reflorir", "remir", "renhir", "ressequir", "retransir", "suquir", "susquir", "transir": return true
    default: return false
    }
  }
  
  /* true if verb NOT conjugated in the first person singular only 
      Note: this property should probably be renamed */
  var firstPersonSingularOnly: Bool {
    switch infinitive {
    case "abolir", "aborrir", "acupremir", "adurir", "apodrir", "balir", "banir", "barrir", "bramir", "brandir", "branquir", "buir", "carpir", "cernir", "colorir", "comburir", "comedir", "delir", "demolir", "demulcir", "descolorir", "descomedir", "emolir", "enganir", "esmarrir", "excelir", "extorquir", "fremir", "ganir", "guarir", "languir", "monir", "multicolorir", "parturir", "premir", "pruir", "prurir", "puir", "raer", "rebolir", "recolorir", "relinquir", "relinqüir", "reprurir", "retorquir", "retorqüir", "ruir", "soer": return true
    default: return false
    }
  }
  
  
  /* Initializes a verb given an infinitive form - if the infinitive is invalid, returns nil */
  init?(infinitive: String) {
    // remove invalid chars
    let possibleInfinitive = removeInvalidCharactersFrom(infinitive)
    
    // only create new Verb if structure of infinitive is valid
    if hasValidEnding(possibleInfinitive) {
      self.infinitive = possibleInfinitive
      self.ending = self.infinitive.substring(self.infinitive.length() - 2)
      
      // generate all four infinitive variants
      compileInfinitiveVariants()
      
      // generate the verb stems for the four variants
      compileStemVariants()
    } else {
      return nil
    }
  }
  
  
  /* Removes all spaces and non-Portuguese letters from a string.
     Note: the input string must be lowercase. */
  private func removeInvalidCharactersFrom(input: String) -> String {
    var output = ""
    var lastCharacterWasADash = false
    
    for character in input.characters {
      switch character {
      case "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
      "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u",
      "v", "w", "x", "y", "z", "á", "à", "ã", "ç", "é", "ê",
      "í", "ó", "õ", "ô", "ú", "ü":
        output.append(character)
        lastCharacterWasADash = false
      case "-", "‐", "‑", "‒", "–", "—":
        // remove all consecutive dashes/hyphens after the first and
        // standardize it to the default "dash" found on a keyboard
        if !lastCharacterWasADash {
          output.append(Character("-"))
          lastCharacterWasADash = true
        }
      default:
        lastCharacterWasADash = false
      }
    }
    
    return output
  }
  
  
  /* Returns true only if the string has one of the following suffixes: "ar", "er", "ir", "por", "pôr". */
  private func hasValidEnding(s: String) -> Bool {
    if s.length() < 2 {
      return false
    }
    if s == "pôr" {
      return true
    }
    return s.hasSuffix("ar") || s.hasSuffix("er") || s.hasSuffix("ir") || s.hasSuffix("por")
  }
  
  
  /* Set this Verb's four infinitives: one for each combination of BP/EP and pre-AO/post-AO. */
  private mutating func compileInfinitiveVariants() {
    var variantIndex = 0
    while let variant = Variant(rawValue: variantIndex) {
      infinitiveVariants[variantIndex] = getInfinitiveFor(variant)
      ++variantIndex
    }
  }
  
  
  /* Set this Verb's four stems: one for each combination of BP/EP and pre-AO/post-AO. */
  private mutating func compileStemVariants() {
    //var variantIndex = 0 // what?
    for i in 0...3 {
      stemVariants[i] = infinitiveVariants[i].substring(0, endIndex: infinitiveVariants[i].length() - 2)
    }
  }
  
  
  /* Given a Variant (representing a combination of BP/EP and pre-AO/post-AO),
     return the correct infinitive form. */
  private func getInfinitiveFor(variant: Variant) -> String {
    switch variant {
    case .BPWithAccord:
      switch infinitive {
      case "accionar":
        return "acionar";
      case "activar":
        return "ativar";
      case "actualizar":
        return "atualizar";
      case "actuar":
        return "atuar";
      case "adjectivar":
        return "adjetivar";
      case "agro-alimentar":
        return "agroalimentar";
      case "anti-sepsiar":
        return "antissepsiar";
      case "argüir":
        return "arguir";
      case "arquitectar":
        return "arquitetar";
      case "auto-abastecer":
        return "autoabastecer";
      case "auto-administrar":
        return "autoadministrar";
      case "auto-excitar":
        return "autoexcitar";
      case "auto-excluir":
        return "autoexcluir";
      case "auto-sugestionar":
        return "autossugestionar";
      case "auto-suspender":
        return "autossuspender";
      case "baptizar":
        return "batizar";
      case "co-administrar":
        return "coadministrar";
      case "co-arrendar":
        return "coarrendar";
      case "co-delinquir", "co-delinqüir":
        return "codelinquir";
      case "co-dirigir":
        return "codirigir";
      case "co-editar":
        return "coeditar";
      case "co-financiar":
        return "cofinanciar";
      case "co-gerir":
        return "cogerir";
      case "co-incinerar":
        return "coincinerar";
      case "co-litigar":
        return "colitigar";
      case "co-obrigar":
        return "coobrigar";
      case "co-participar":
        return "coparticipar";
      case "co-produzir":
        return "coproduzir";
      case "co-responsabilizar":
        return "corresponsabilizar";
      case "coleccionar":
        return "colecionar";
      case "concetualizar":
        return "conceptualizar";
      case "confecionar":
        return "confeccionar";
      case "contra-indicar":
        return "contraindicar";
      case "contra-informar":
        return "contrainformar";
      case "contra-ordenar":
        return "contraordenar";
      case "contra-revolucionar":
        return "contrarrevolucionar";
      case "contra-selar":
        return "contrasselar";
      case "dececionar":
        return "decepcionar";
      case "delinqüir":
        return "delinquir";
      case "deliqüescer":
        return "deliquescer";
      case "desactivar":
        return "desativar";
      case "desactualizar":
        return "desatualizar";
      case "desarquitectar":
        return "desarquitetar";
      case "desbaptizar":
        return "desbatizar";
      case "desensangüentar":
        return "desensanguentar";
      case "desfreqüentar":
        return "desfrequentar";
      case "desmilingüir":
        return "desmilinguir";
      case "difractar":
        return "difratar";
      case "direccionar":
        return "direcionar";
      case "efectivar":
        return "efetivar";
      case "efectuar":
        return "efetuar";
      case "ensangüentar":
        return "ensanguentar";
      case "eqüidistar":
        return "equidistar";
      case "eqüipoler":
        return "equipoler";
      case "eqüiponderar":
        return "equiponderar";
      case "exactificar":
        return "exatificar";
      case "exigüificar":
        return "exiguificar";
      case "facturar":
        return "faturar";
      case "freqüentar":
        return "frequentar";
      case "inactivar":
        return "inativar";
      case "infra-escapular":
        return "infraescapular";
      case "injectar":
        return "injetar";
      case "inspeccionar":
        return "inspecionar";
      case "inspectar":
        return "inspetar";
      case "interactuar":
        return "interatuar";
      case "intercetar":
        return "interceptar";
      case "intersectar":
        return "intersetar";
      case "liqüefazer":
        return "liquefazer";
      case "liqüescer":
        return "liquescer";
      case "liqüidar":
        return "liquidar";
      case "liqüidificar":
        return "liquidificar";
      case "percecionar":
        return "percepcionar";
      case "perfetibilizar":
        return "perfectibilizar";
      case "preleccionar":
        return "prelecionar";
      case "projectar":
        return "projetar";
      case "reactivar":
        return "reativar";
      case "reactualizar":
        return "reatualizar";
      case "rebaptizar":
        return "rebatizar";
      case "rececionar":
        return "recepcionar";
      case "recetar":
        return "receptar";
      case "redargüir":
        return "redarguir";
      case "redireccionar":
        return "redirecionar";
      case "reflectir":
        return "refletir";
      case "relinqüir":
        return "relinquir";
      case "retractar":
        return "retratar";
      case "retroprojectar":
        return "retroprojetar";
      case "sectorizar":
        return "setorizar";
      case "seleccionar":
        return "selecionar";
      case "selectar":
        return "seletar";
      case "seqüenciar":
        return "sequenciar";
      case "seqüestrar":
        return "sequestrar";
      case "sobreelevar":
        return "sobre-elevar";
      case "sobreendividar":
        return "sobre-endividar";
      case "sobreerguer":
        return "sobre-erguer";
      case "sobreexaltar":
        return "sobre-exaltar";
      case "sobreexceder":
        return "sobre-exceder";
      case "sobreexcitar":
        return "sobre-excitar";
      case "sobreexpor":
        return "sobre-expor";
      case "subjectivar":
        return "subjetivar";
      case "subjectivizar":
        return "subjetivizar";
      case "supra-excitar":
        return "supraexcitar";
      case "teledetetar":
        return "teledetectar";
      case "traccionar":
        return "tracionar";
      case "tranqüilizar":
        return "tranquilizar";
      case "transaccionar":
        return "transacionar";
      case "ultra-romantizar":
        return "ultrarromantizar";
      case "ungüentar":
        return "unguentar";
      default:
        return infinitive // weird
        //return infinitive.stringByReplacingOccurrencesOfString("ü", withString: "u", options: nil, range: nil)
      }
    case .BPWithoutAccord:
      switch infinitive {
      case "accionar":
        return "acionar";
      case "activar":
        return "ativar";
      case "actualizar":
        return "atualizar";
      case "actuar":
        return "atuar";
      case "adjectivar":
        return "adjetivar";
      case "agroalimentar":
        return "agro-alimentar";
      case "amnistiar":
        return "anistiar";
      case "antissepsiar":
        return "anti-sepsiar";
      case "arguir":
        return "argüir";
      case "arquitectar":
        return "arquitetar";
      case "autoabastecer":
        return "auto-abastecer";
      case "autoadministrar":
        return "auto-administrar";
      case "autoexcitar":
        return "auto-excitar";
      case "autoexcluir":
        return "auto-excluir";
      case "autossugestionar":
        return "auto-sugestionar";
      case "autossuspender":
        return "auto-suspender";
      case "baptizar":
        return "batizar";
      case "coadministrar":
        return "co-administrar";
      case "coarrendar":
        return "co-arrendar";
      case "co-delinquir", "codelinquir":
        return "co-delinqüir";
      case "codirigir":
        return "co-dirigir";
      case "coeditar":
        return "co-editar";
      case "cofinanciar":
        return "co-financiar";
      case "cogerir":
        return "co-gerir";
      case "coincinerar":
        return "co-incinerar";
      case "colitigar":
        return "co-litigar";
      case "coobrigar":
        return "co-obrigar";
      case "coparticipar":
        return "co-participar";
      case "coproduzir":
        return "co-produzir";
      case "corresponsabilizar":
        return "co-responsabilizar";
      case "coatar":
        return "coactar";
      case "coleccionar":
        return "colecionar";
      case "concetualizar":
        return "conceptualizar";
      case "confecionar":
        return "confeccionar";
      case "contraindicar":
        return "contra-indicar";
      case "contrainformar":
        return "contra-informar";
      case "contraordenar":
        return "contra-ordenar";
      case "contrarrevolucionar":
        return "contra-revolucionar";
      case "contrasselar":
        return "contra-selar";
      case "dececionar":
        return "decepcionar";
      case "delinquir":
        return "delinqüir";
      case "deliquescer":
        return "deliqüescer";
      case "desactivar":
        return "desativar";
      case "desactualizar":
        return "desatualizar";
      case "desarquitectar":
        return "desarquitetar";
      case "desbaptizar":
        return "desbatizar";
      case "desensanguentar":
        return "desensangüentar";
      case "desfrequentar":
        return "desfreqüentar";
      case "desmilinguir":
        return "desmilingüir";
      case "difractar":
        return "difratar";
      case "direccionar":
        return "direcionar";
      case "efectivar":
        return "efetivar";
      case "efectuar":
        return "efetuar";
      case "ensanguentar":
        return "ensangüentar";
      case "equidistar":
        return "eqüidistar";
      case "equipoler":
        return "eqüipoler";
      case "equiponderar":
        return "eqüiponderar";
      case "exactificar":
        return "exatificar";
      case "exiguificar":
        return "exigüificar";
      case "facturar":
        return "faturar";
      case "frequentar":
        return "freqüentar";
      case "inactivar":
        return "inativar";
      case "infraescapular":
        return "infra-escapular";
      case "injectar":
        return "injetar";
      case "inspeccionar":
        return "inspecionar";
      case "inspectar":
        return "inspetar";
      case "interactuar":
        return "interatuar";
      case "intercetar":
        return "interceptar";
      case "intersetar":
        return "intersectar";
      case "jactar":
        return "jatar";
      case "liquefazer":
        return "liqüefazer";
      case "liquescer":
        return "liqüescer";
      case "liquidar":
        return "liqüidar";
      case "liquidificar":
        return "liqüidificar";
      case "percecionar":
        return "percepcionar";
      case "perfetibilizar":
        return "perfectibilizar";
      case "preleccionar":
        return "prelecionar";
      case "projectar":
        return "projetar";
      case "reactivar":
        return "reativar";
      case "reactualizar":
        return "reatualizar";
      case "rebaptizar":
        return "rebatizar";
      case "rececionar":
        return "recepcionar";
      case "recetar":
        return "receptar";
      case "redarguir":
        return "redargüir";
      case "redireccionar":
        return "redirecionar";
      case "reflectir":
        return "refletir";
      case "relinquir":
        return "relinqüir";
      case "retractar":
        return "retratar";
      case "retroprojectar":
        return "retroprojetar";
      case "sectorizar":
        return "setorizar";
      case "seleccionar":
        return "selecionar";
      case "selectar":
        return "seletar";
      case "sequenciar":
        return "seqüenciar";
      case "sequestrar":
        return "seqüestrar";
      case "sobre-elevar":
        return "sobreelevar";
      case "sobre-endividar":
        return "sobreendividar";
      case "sobre-erguer":
        return "sobreerguer";
      case "sobre-exaltar":
        return "sobreexaltar";
      case "sobre-exceder":
        return "sobreexceder";
      case "sobre-excitar":
        return "sobreexcitar";
      case "sobre-expor":
        return "sobreexpor";
      case "subjectivar":
        return "subjetivar";
      case "subjectivizar":
        return "subjetivizar";
      case "supraexcitar":
        return "supra-excitar";
      case "teledetetar":
        return "teledetectar";
      case "traccionar":
        return "tracionar";
      case "tranquilizar":
        return "tranqüilizar";
      case "transaccionar":
        return "transacionar";
      case "ultrarromantizar":
        return "ultra-romantizar";
      case "unguentar":
        return "ungüentar";
      default:
        return infinitive;
      }
    case .EPWithAccord:
      switch infinitive {
      case "accionar":
        return "acionar";
      case "activar":
        return "ativar";
      case "actualizar":
        return "atualizar";
      case "actuar":
        return "atuar";
      case "adjectivar":
        return "adjetivar";
      case "adoptar":
        return "adotar";
      case "afectar":
        return "afetar";
      case "agro-alimentar":
        return "agroalimentar";
      case "anti-sepsiar":
        return "antissepsiar";
      case "argüir":
        return "arguir";
      case "arquitectar":
        return "arquitetar";
      case "auto-abastecer":
        return "autoabastecer";
      case "auto-administrar":
        return "autoadministrar";
      case "auto-excitar":
        return "autoexcitar";
      case "auto-excluir":
        return "autoexcluir";
      case "auto-sugestionar":
        return "autossugestionar";
      case "auto-suspender":
        return "autossuspender";
      case "baptizar":
        return "batizar";
      case "circunspeccionar":
        return "circunspecionar";
      case "co-administrar":
        return "coadministrar";
      case "co-arrendar":
        return "coarrendar";
      case "co-delinquir", "co-delinqüir":
        return "codelinquir";
      case "co-dirigir":
        return "codirigir";
      case "co-editar":
        return "coeditar";
      case "co-financiar":
        return "cofinanciar";
      case "co-gerir":
        return "cogerir";
      case "co-incinerar":
        return "coincinerar";
      case "co-litigar":
        return "colitigar";
      case "co-obrigar":
        return "coobrigar";
      case "co-participar":
        return "coparticipar";
      case "co-produzir":
        return "coproduzir";
      case "co-responsabilizar":
        return "corresponsabilizar";
      case "coactar":
        return "coatar";
      case "coarctar":
        return "coartar";
      case "coleccionar":
        return "colecionar";
      case "colectar":
        return "coletar";
      case "colectivizar":
        return "coletivizar";
      case "confeccionar":
        return "confecionar";
      case "conjecturar":
        return "conjeturar";
      case "contra-indicar":
        return "contraindicar";
      case "contra-informar":
        return "contrainformar";
      case "contra-ordenar":
        return "contraordenar";
      case "contra-revolucionar":
        return "contrarrevolucionar";
      case "contra-selar":
        return "contrasselar";
      case "decepcionar":
        return "dececionar";
      case "dejectar":
        return "dejetar";
      case "delinqüir":
        return "delinquir";
      case "deliqüescer":
        return "deliquescer";
      case "desactivar":
        return "desativar";
      case "desactualizar":
        return "desatualizar";
      case "desafectar":
        return "desafetar";
      case "desarquitectar":
        return "desarquitetar";
      case "desbaptizar":
        return "desbatizar";
      case "deselectrizar":
        return "deseletrizar";
      case "desensangüentar":
        return "desensanguentar";
      case "desfreqüentar":
        return "desfrequentar";
      case "desinfeccionar":
        return "desinfecionar";
      case "desinfectar":
        return "desinfetar";
      case "desmilingüir":
        return "desmilinguir";
      case "detectar":
        return "detetar";
      case "dialectizar":
        return "dialetizar";
      case "difractar":
        return "difratar";
      case "direccionar":
        return "direcionar";
      case "efectivar":
        return "efetivar";
      case "efectuar":
        return "efetuar";
      case "ejectar":
        return "ejetar";
      case "electrificar":
        return "eletrificar";
      case "electrizar":
        return "eletrizar";
      case "electrocutar":
        return "eletrocutar";
      case "electrocutir":
        return "eletrocutir";
      case "electrolisar":
        return "eletrolisar";
      case "ensangüentar":
        return "ensanguentar";
      case "eqüidistar":
        return "equidistar";
      case "eqüipoler":
        return "equipoler";
      case "eqüiponderar":
        return "equiponderar";
      case "exactificar":
        return "exatificar";
      case "excepcionar":
        return "excecionar";
      case "exceptuar":
        return "excetuar";
      case "exigüificar":
        return "exiguificar";
      case "expectorar":
        return "expetorar";
      case "extractar":
        return "extratar";
      case "factorizar":
        return "fatorizar";
      case "facturar":
        return "faturar";
      case "flectir":
        return "fletir";
      case "fraccionar":
        return "fracionar";
      case "fracturar":
        return "fraturar";
      case "freqüentar":
        return "frequentar";
      case "genuflectir":
        return "genufletir";
      case "inactivar":
        return "inativar";
      case "infeccionar":
        return "infecionar";
      case "infectar":
        return "infetar";
      case "inflectir":
        return "infletir";
      case "infra-escapular":
        return "infraescapular";
      case "injectar":
        return "injetar";
      case "inspeccionar":
        return "inspecionar";
      case "inspectar":
        return "inspetar";
      case "insurreccionar":
        return "insurrecionar";
      case "interactuar":
        return "interatuar";
      case "interceptar":
        return "intercetar";
      case "interjeccionar":
        return "interjecionar";
      case "invectivar":
        return "invetivar";
      case "leccionar":
        return "lecionar";
      case "liqüefazer":
        return "liquefazer";
      case "liqüescer":
        return "liquescer";
      case "liqüidar":
        return "liquidar";
      case "liqüidificar":
        return "liquidificar";
      case "manufacturar":
        return "manufaturar";
      case "objectar":
        return "objetar";
      case "objectivar":
        return "objetivar";
      case "olfactar":
        return "olfatar";
      case "optimizar":
        return "otimizar";
      case "percepcionar":
        return "percecionar";
      case "perspectivar":
        return "perspetivar";
      case "preleccionar":
        return "prelecionar";
      case "projectar":
        return "projetar";
      case "prospectar":
        return "prospetar";
      case "reactivar":
        return "reativar";
      case "reactualizar":
        return "reatualizar";
      case "readoptar":
        return "readotar";
      case "rebaptizar":
        return "rebatizar";
      case "recepcionar":
        return "rececionar";
      case "receptar":
        return "recetar";
      case "rectificar":
        return "retificar";
      case "redargüir":
        return "redarguir";
      case "redireccionar":
        return "redirecionar";
      case "reflectir":
        return "refletir";
      case "refractar":
        return "refratar";
      case "relinqüir":
        return "relinquir";
      case "retractar":
        return "retratar";
      case "retroflectir":
        return "retrofletir";
      case "retroprojectar":
        return "retroprojetar";
      case "setorizar":
        return "sectorizar";
      case "seleccionar":
        return "selecionar";
      case "selectar":
        return "seletar";
      case "seqüenciar":
        return "sequenciar";
      case "seqüestrar":
        return "sequestrar";
      case "sobreelevar":
        return "sobre-elevar";
      case "sobreendividar":
        return "sobre-endividar";
      case "sobreerguer":
        return "sobre-erguer";
      case "sobreexaltar":
        return "sobre-exaltar";
      case "sobreexceder":
        return "sobre-exceder";
      case "sobreexcitar":
        return "sobre-excitar";
      case "sobreexpor":
        return "sobre-expor";
      case "subjectivar":
        return "subjetivar";
      case "subjectivizar":
        return "subjetivizar";
      case "supra-excitar":
        return "supraexcitar";
      case "susceptibilizar":
        return "suscetibilizar";
      case "tactear":
        return "tatear";
      case "teledetectar":
        return "teledetetar";
      case "traccionar":
        return "tracionar";
      case "tranqüilizar":
        return "tranquilizar";
      case "transaccionar":
        return "transacionar";
      case "ultra-romantizar":
        return "ultrarromantizar";
      case "ungüentar":
        return "unguentar";
      case "vectorizar":
        return "vetorizar";
      default:
        return infinitive
        //return infinitive.stringByReplacingOccurrencesOfString("ü", withString: "u", options: nil, range: nil)
      }
    case .EPWithoutAccord:
      switch infinitive {
      case "acionar":
        return "accionar";
      case "ativar":
        return "activar";
      case "atualizar":
        return "actualizar";
      case "atuar":
        return "actuar";
      case "adjetivar":
        return "adjectivar";
      case "adotar":
        return "adoptar";
      case "afetar":
        return "afectar";
      case "agroalimentar":
        return "agro-alimentar";
      case "amidalar":
        return "amigdalar";
      case "anistiar":
        return "amnistiar";
      case "antissepsiar":
        return "anti-sepsiar";
      case "aquapunturar":
        return "aquapuncturar";
      case "argüir":
        return "arguir";
      case "arquitetar":
        return "arquitectar";
      case "autoabastecer":
        return "auto-abastecer";
      case "autoadministrar":
        return "auto-administrar";
      case "autoexcitar":
        return "auto-excitar";
      case "autoexcluir":
        return "auto-excluir";
      case "autossugestionar":
        return "auto-sugestionar";
      case "autossuspender":
        return "auto-suspender";
      case "batizar":
        return "baptizar";
      case "bissetar":
        return "bissectar";
      case "caraterizar":
        return "caracterizar";
      case "circunspecionar":
        return "circunspeccionar";
      case "coadministrar":
        return "co-administrar";
      case "coarrendar":
        return "co-arrendar";
      case "codelinquir", "co-delinqüir":
        return "co-delinquir";
      case "codirigir":
        return "co-dirigir";
      case "coeditar":
        return "co-editar";
      case "cofinanciar":
        return "co-financiar";
      case "cogerir":
        return "co-gerir";
      case "coincinerar":
        return "co-incinerar";
      case "colitigar":
        return "co-litigar";
      case "coobrigar":
        return "co-obrigar";
      case "coparticipar":
        return "co-participar";
      case "coproduzir":
        return "co-produzir";
      case "corresponsabilizar":
        return "co-responsabilizar";
      case "coatar":
        return "coactar";
      case "coartar":
        return "coarctar";
      case "colecionar":
        return "coleccionar";
      case "coletar":
        return "colectar";
      case "coletivizar":
        return "colectivizar";
      case "confecionar":
        return "confeccionar";
      case "conjeturar":
        return "conjecturar";
      case "contraindicar":
        return "contra-indicar";
      case "contrainformar":
        return "contra-informar";
      case "contraordenar":
        return "contra-ordenar";
      case "contrarrevolucionar":
        return "contra-revolucionar";
      case "contrasselar":
        return "contra-selar";
      case "datilar":
        return "dactilar";
      case "datilografar":
        return "dactilografar";
      case "dececionar":
        return "decepcionar";
      case "defletir":
        return "deflectir";
      case "dejetar":
        return "dejectar";
      case "delinqüir":
        return "delinquir";
      case "deliqüescer":
        return "deliquescer";
      case "desativar":
        return "desactivar";
      case "desatualizar":
        return "desactualizar";
      case "desafetar":
        return "desafectar";
      case "desarquitetar":
        return "desarquitectar";
      case "desbatizar":
        return "desbaptizar";
      case "descaraterizar":
        return "descaracterizar";
      case "deseletrizar":
        return "deselectrizar";
      case "desensangüentar":
        return "desensanguentar";
      case "desfreqüentar":
        return "desfrequentar";
      case "desinfecionar":
        return "desinfeccionar";
      case "desinfetar":
        return "desinfectar";
      case "desmilingüir":
        return "desmilinguir";
      case "detetar":
        return "detectar";
      case "dialetizar":
        return "dialectizar";
      case "difratar":
        return "difractar";
      case "direcionar":
        return "direccionar";
      case "efetivar":
        return "efectivar";
      case "efetuar":
        return "efectuar";
      case "ejetar":
        return "ejectar";
      case "eletrificar":
        return "electrificar";
      case "eletrizar":
        return "electrizar";
      case "eletrocutar":
        return "electrocutar";
      case "eletrocutir":
        return "electrocutir";
      case "eletrolisar":
        return "electrolisar";
      case "ensangüentar":
        return "ensanguentar";
      case "eqüidistar":
        return "equidistar";
      case "eqüipoler":
        return "equipoler";
      case "eqüiponderar":
        return "equiponderar";
      case "exatificar":
        return "exactificar";
      case "excecionar":
        return "excepcionar";
      case "excetuar":
        return "exceptuar";
      case "exigüificar":
        return "exiguificar";
      case "expetorar":
        return "expectorar";
      case "extratar":
        return "extractar";
      case "facionar":
        return "faccionar";
      case "fatorizar":
        return "factorizar";
      case "faturar":
        return "facturar";
      case "fletir":
        return "flectir";
      case "fracionar":
        return "fraccionar";
      case "fraturar":
        return "fracturar";
      case "freqüentar":
        return "frequentar";
      case "genufletir":
        return "genuflectir";
      case "inativar":
        return "inactivar";
      case "infecionar":
        return "infeccionar";
      case "infetar":
        return "infectar";
      case "infletir":
        return "inflectir";
      case "infraescapular":
        return "infra-escapular";
      case "injetar":
        return "injectar";
      case "inspecionar":
        return "inspeccionar";
      case "inspetar":
        return "inspectar";
      case "insurrecionar":
        return "insurreccionar";
      case "interatuar":
        return "interactuar";
      case "intercetar":
        return "interceptar";
      case "interjecionar":
        return "interjeccionar";
      case "intersetar":
        return "intersectar";
      case "invetivar":
        return "invectivar";
      case "jatanciar":
        return "jactanciar";
      case "jatar":
        return "jactar";
      case "lecionar":
        return "leccionar";
      case "liqüefazer":
        return "liquefazer";
      case "liqüescer":
        return "liquescer";
      case "liqüidar":
        return "liquidar";
      case "liqüidificar":
        return "liquidificar";
      case "manufaturar":
        return "manufacturar";
      case "objetar":
        return "objectar";
      case "objetivar":
        return "objectivar";
      case "olfatar":
        return "olfactar";
      case "otimizar":
        return "optimizar";
      case "percecionar":
        return "percepcionar";
      case "perfetibilizar":
        return "perfectibilizar";
      case "perspetivar":
        return "perspectivar";
      case "prelecionar":
        return "preleccionar";
      case "projetar":
        return "projectar";
      case "prospetar":
        return "prospectar";
      case "reativar":
        return "reactivar";
      case "reatualizar":
        return "reactualizar";
      case "readotar":
        return "readoptar";
      case "rebatizar":
        return "rebaptizar";
      case "rececionar":
        return "recepcionar";
      case "recetar":
        return "receptar";
      case "retificar":
        return "rectificar";
      case "redargüir":
        return "redarguir";
      case "redirecionar":
        return "redireccionar";
      case "refletir":
        return "reflectir";
      case "refratar":
        return "refractar";
      case "relinqüir":
        return "relinquir";
      case "retratar":
        return "retractar";
      case "retrofletir":
        return "retroflectir";
      case "retroprojetar":
        return "retroprojectar";
      case "secionar":
        return "seccionar";
      case "setorizar":
        return "sectorizar";
      case "selecionar":
        return "seleccionar";
      case "seletar":
        return "selectar";
      case "setuplicar":
        return "septuplicar";
      case "seqüenciar":
        return "sequenciar";
      case "seqüestrar":
        return "sequestrar";
      case "sobre-elevar":
        return "sobreelevar";
      case "sobre-endividar":
        return "sobreendividar";
      case "sobre-erguer":
        return "sobreerguer";
      case "sobre-exaltar":
        return "sobreexaltar";
      case "sobre-exceder":
        return "sobreexceder";
      case "sobre-excitar":
        return "sobreexcitar";
      case "sobre-expor":
        return "sobreexpor";
      case "subjetivar":
        return "subjectivar";
      case "subjetivizar":
        return "subjectivizar";
      case "sutilizar":
        return "subtilizar";
      case "supraexcitar":
        return "supra-excitar";
      case "suscetibilizar":
        return "susceptibilizar";
      case "tatear":
        return "tactear";
      case "teledetetar":
        return "teledetectar";
      case "tracionar":
        return "traccionar";
      case "tranqüilizar":
        return "tranquilizar";
      case "transacionar":
        return "transaccionar";
      case "ultrarromantizar":
        return "ultra-romantizar";
      case "ungüentar":
        return "unguentar";
      case "vetorizar":
        return "vectorizar";
      case "volutuar":
        return "voluptuar";
      default:
        return infinitive
        //return infinitive.stringByReplacingOccurrencesOfString("ü", withString: "u", options: nil, range: nil)
      }
    }
  }
}

/* Store conjugations for the auxiliary verbs.
   Note: due to a bug in Xcode 7 these must be declared on separate lines. */
private var estarTable: [[[String?]]]!
private var haverTable: [[[String?]]]!
private var serTable: [[[String?]]]!
private var terTable: [[[String?]]]!


/* Fills the conjugation tables for the four auxiliary verbs "haver", "ter", "estar", and "ser".
   Note: This function MUST be run before any complete conjugation of a verb is possible, as these
   auxiliary verbs are needed for the compound, progressive, and passive tenses. */
func prepareAuxTables() {
  let haver = Conjugator(verb: Verb(infinitive: "haver"))
  let ter = Conjugator(verb: Verb(infinitive: "ter"))
  let estar = Conjugator(verb: Verb(infinitive: "estar"))
  let ser = Conjugator(verb: Verb(infinitive: "ser"))

  // "haver" and "ter" stop at Tense.PastParticiple because the following tenses are
  // compound tenses, which require already knowing the simple conjugations of "haver" and "ter" :P
  // chicken and egg scenario
  ter!.conjugateAllTensesUpTo(Tense.PastParticiple)
  haver!.conjugateAllTensesUpTo(Tense.PastParticiple)
  
  terTable = ter!.conjTable
  haverTable = haver!.conjTable

  
  // since we've already finished with "haver" and "ter", we can do all tenses, including the
  // compound ones, for "estar" and "ser"
  estar!.conjugateAllTensesUpTo(Tense.CompoundImpersonalInfinitive)
  estarTable = estar!.conjTable
  ser!.conjugateAllTensesUpTo(Tense.CompoundImpersonalInfinitive)
  serTable = ser!.conjTable
}


/* Provides a mechanism to fully conjugate a Portuguese verb (Verb) in the simple, compound,
   progressive, and passive tenses.  Each Conjugator object is restricted to a single Verb.
   This is the interface through which the application may generate conjugation tables.
   The class allows for object pronouns to be correctly inserted into each conjugation as well. */
class Conjugator {
  
  /* The verb to be conjugated */
  let verb: Verb!
  
  /* Holds the simple and compound conjugations of "verb" for all four Variants */
  var conjTable: [[[String?]]]!
  
  /* Reusable: for each Variant, used for each tense to store the 6 conjugations, one per
     Person: 1ps 2ps 3ps 1pp 2pp 3pp */
  var bpWithAO, bpWithoutAO, epWithAO, epWithoutAO: [String?]!
  
  /* Reusable: for the current Variant and Tense, stores the 6 endings to be attached to the stems in
     accordance with the rules specified in "stems" */
  var ends: [String?]!
  
  /* Reusable: for the current Tense, stores an int flag for each of the 6 Persons indicating which stems
     are attached to the endings in "ends" for each Variant.  It's kind of complicated but it was the best
     strategy I could come up with. */
  var stems: [Int] = []
  
  /* Reusable: for the current Tense, store all necessary stems for complete conjugation. */
  var stem, stem2, stem3, stem4: String!
  
  
  /* If passed a valid Verb, initializes a new Conjugator object.  Otherwise, returns nil. */
  init?(verb: Verb?) {
    self.verb = verb
    resetSharedProperties()
    if verb == nil {
        return nil
    }
  }
  
  
  /* Initialize the conjugation table for this verb and fill it with nil values. */
  private func allocateConjugationTable() {
    conjTable = [[[String?]]](count: Tense.count(), repeatedValue:
      [[String?]](count: Variant.count(), repeatedValue:
        [String?](count: Person.count(), repeatedValue: nil)))
  }
  
  
  /* Sets all reusable properties to nil. */
  private func resetSharedProperties() {
    bpWithAO = [String?](count: 6, repeatedValue: nil)
    bpWithoutAO = [String?](count: 6, repeatedValue: nil)
    epWithAO = [String?](count: 6, repeatedValue: nil)
    epWithoutAO = [String?](count: 6, repeatedValue: nil)
    
    ends = [String?](count: 6, repeatedValue: nil)
    stems = [Int](count: 6, repeatedValue: 1)
    stem = nil; stem2 = nil; stem3 = nil; stem4 = nil
  }
  
  
  /* For a given String, takes the character nth from last and replaces it with the value of "c".
     Returns the result.  This method is meant to modify the stem variables. */
  private func chCharToLast(n: Int, stem: String, c: Character) -> String {
    let len = stem.characters.count
    
    // don't worry about ensuring n > 0 because a crash will indicate another method has an issue
    // in other words, n should never be less than 1
    var newStem: String = stem.substring(0, endIndex: len - n)
    newStem.append(c)
    
    // throw on the rest of the characters after the nth from last
    if n > 1 {
      newStem += stem.substringFromIndex(stem.startIndex.advancedBy(len - n + 1))
    }
    return newStem
  }
  
  
  /* For a given String, takes the character nth from last and replaces it with the value of "with".
     Returns the result.  This method is meant to modify the stem variables. */
  private func replaceCharacterFromEnd(n: Int, inString: String, with: String) -> String {
    let len = inString.characters.count
    
    // don't worry about ensuring n > 0 because a crash will indicate another method has an issue
    // in other words, n should never be less than 1
    var newStem: String = inString.substring(0, endIndex: len - n)
    newStem += with
    
    // throw on the rest of the characters after the nth from last
    if n > 1 {
      newStem += inString.substringFromIndex(inString.startIndex.advancedBy(len - n + 1))
    }
    return newStem
  }
  
  
  /* Returns the conjugation type for this verb in the simple present indicative tense. */
  private func getPresentIndicativeVerbType() -> String? {
    if verb.darDerivative { return "-DAR" }
    if verb.estarDerivative { return "-ESTAR" }
    if verb.lerDerivative { return "-LER" }
    if verb.terDerivative { return "-TER" }
    if verb.verDerivative { return "-VER" }
    if verb.virDerivative { return "-VIR" }
    
    switch verb.infinitive {
    case "abaiucar", "afiuzar", "ajesuitar", "agenciar", "ansiar", "apaular", "aprazer", "apresenciar", "arremediar", "aspergir", "ateizar", "aunar", "aviusar", "aziumar", "cadenciar", "cerzir", "comerciar", "consumir", "convergir", "crer", "dar", "denegrir", "desaprazer", "desarremediar", "descrer", "desembaular", "desmilinguir", "desnegociar", "despremiar", "desremediar", "destruir", "diligenciar", "divergir", "embaular", "embaucar", "ensimesmar", "enviusar", "esmiuçar", "estar", "explodir", "faiscar", "faular", "frigir", "fugir", "haver", "incendiar", "intermediar", "ir", "ler", "licenciar", "mediar", "obsequiar", "odiar", "parar", "pôr", "prazer", "premiar", "presenciar", "promediar", "puitar", "reaprazer", "requerer", "rer", "retorquir", "retorqüir", "reunir", "rir", "ruidar", "saudar", "ser", "sobreir", "sobresser", "sortir", "subir", "sumir", "ter", "tossir", "ver", "vir": return verb.infinitive.uppercaseString
    case "desmilingüir": return "desmilinguir" // should this case be merged??
    default: break
    }
    
    // start trying to match by suffix, from longer down to shorter, as longer is more specific
    if verb.infinitive.hasSuffix("balaustrar") { return "-BALAUSTRAR" }
    if verb.infinitive.hasSuffix("construir") { return "-CONSTRUIR" }
    if verb.infinitive.hasSuffix("delinquir") || verb.infinitive.hasSuffix("delinqüir") { return "-DELINQUIR" }
    if verb.infinitive.hasSuffix("negociar") { return "-NEGOCIAR" }
    if verb.infinitive.hasSuffix("mobiliar") { return "-MOBILIAR" }
    if verb.infinitive.hasSuffix("engolir") { return "-ENGOLIR" }
    if verb.infinitive.hasSuffix("entupir") { return "-ENTUPIR" }
    if verb.infinitive.hasSuffix("gauchar") { return "-GAUCHAR" }
    
    for v in [ "acudir", "anquir", "arguir", "baular", "ciumar", "cobrir",
      "cuspir", "dormir", "embair", "erguer", "gredir", "guizar", "guspir",
      "inguar", "inguir", "inquar", "perder", "prazer", "querer", "quizar",
      "ruinar", "sorrir", "trazer", "viuvar" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    if verb.infinitive.hasSuffix("argüir") { return "-ARGUIR" }
    if verb.infinitive.hasSuffix("ingüir") { return "-INGUIR" }
    
    for v in [ "aguar", "aizar", "caber", "dizer", "ectir", "eizar", "ertir",
      "eguar", "eguir", "enhir", "entir", "equar", "ergir", "ernir", "ervir",
      "erzir", "fazer", "iguar", "iquar", "jazer", "medir", "pedir", "oibir",
      "oizar", "ouvir", "parir", "poder", "polir", "saber", "uizar", "valer",
      "egüir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    for v in [ "agir", "edir", "eger", "elir", "emir", "enir", "erir", "etir",
      "guir", "oiar", "quir", "ulir", "uzir", "güer",
      "güir", "qüir" ] {
        if verb.infinitive.hasSuffix(v) {
          return "-" + v.uppercaseString
        }
    }
    
    for v in [ "aer", "air", "cer", "cir", "ear", "ger", "gir", "oar", "oer",
      "por", "uir" ] {
        if verb.infinitive.hasSuffix(v) {
          return "-" + v.uppercaseString
        }
    }
    
    // verb is regular
    for v in [ "ar", "er", "ir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // no match, should never ever happen
    return nil
  }
  
  
  /* Returns the conjugation type for this verb in the simple imperfect indicative tense. */
  private func getImperfectIndicativeVerbType() -> String? {
    if verb.terDerivative { return "-TER" }
    if verb.virDerivative { return "-VIR" }
    
    switch verb.infinitive {
    case "ensimesmar":
      return "ENSIMESMAR"
    case "pôr":
      return "-POR"
    case "ser":
      return "SER"
    case "sobresser":
      return "SOBRESSER"
    case "ter":
      return "TER"
    case "vir":
      return "VIR"
    default:
      break
    }
    
    // start trying to match by suffix, from longer down to shorter, as longer is more specific
    for v in [ "guer", "guir", "quir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    if verb.infinitive.hasSuffix("güir") {
      return "-GUIR"
    }
    
    if verb.infinitive.hasSuffix("qüir") {
      return "-QUIR"
    }
    
    for v in [ "aer", "air", "oer", "oir", "por", "uer", "uir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // verb is regular
    for v in [ "ar", "er", "ir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // no match, should never ever happen
    return nil
  }
  
  
  /* Returns the conjugation type for this verb in the simple preterite perfect indicative tense.
     The result is valid for the simple pluperfect tense as well. */
  private func getPreteriteIndicativeVerbType() -> String? {
    if verb.darDerivative { return "-DAR" }
    if verb.estarDerivative { return "-ESTAR" }
    if verb.terDerivative { return "-TER" }
    if verb.verDerivative { return "-VER" }
    if verb.virDerivative { return "-VIR" }
    
    switch verb.infinitive {
    case "dar", "ensimesmar", "estar", "haver", "ir", "poder", "reaver", "requerer", "ser", "sobreir", "sobresser", "ter", "ver", "vir": return verb.infinitive.uppercaseString
    case "pôr": return "-POR"
    default: break
    }
    
    // start trying to match by suffix, from longer down to shorter, as longer is more specific
    for v in [ "prazer", "querer", "trazer" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    for v in [ "fazer", "dizer" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    for v in [ "aber", "guar", "guir", "quar", "quir"] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    if verb.infinitive.hasSuffix("güir") {
      return "-GUIR"
    }
    
    if verb.infinitive.hasSuffix("qüir") {
      return "-QUIR"
    }
    
    for v in [ "aer", "air", "car", "gar", "oer", "por", "uir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // verb is regular
    for v in [ "ar", "er", "ir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // no match, should never ever happen
    return nil
  }
  
  
  /* Returns the conjugation type for this verb in the simple future indicative tense.
     The result is valid for the simple conditional tense as well. */
  private func getFutureIndicativeVerbType() -> String {
    if verb.infinitive == "ensimesmar" {
      return "ENSIMESMAR"
    }
    
    if verb.infinitive == "pôr" {
      return "PÔR"
    }
    
    for v in [ "trazer", "fazer", "dizer"] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // verb is regular
    return "REGULAR"
  }
  
  /* Returns the conjugation type for this verb in the simple present subjunctive tense. */
  private func getPresentSubjunctiveVerbType() -> String? {
    if verb.darDerivative { return "-DAR" }
    if verb.estarDerivative { return "-ESTAR" }
    
    switch verb.infinitive {
    case "abaiucar", "afiuzar", "ajesuitar", "ansiar", "apaular", "arremediar", "aunar", "aviusar", "aziumar", "dar", "desarremediar", "desembaular", "desremediar", "embaular", "embaucar", "ensimesmar", "esmiuçar", "estar", "explodir", "faiscar", "faular", "haver", "incendiar", "intermediar", "ir", "mediar", "odiar", "promediar", "puitar", "requerer", "reunir", "ruidar", "saudar", "ser", "sobreir", "sobresser": return verb.infinitive.uppercaseString
    case "pôr": return "-POR"
    default: break
    }
    
    // start trying to match by suffix, from longer down to shorter, as longer is more specific
    if verb.infinitive.hasSuffix("balaustrar") { return "-BALAUSTRAR" }
    if verb.infinitive.hasSuffix("delinquir") || verb.infinitive.hasSuffix("delinqüir") { return "-DELINQUIR" }
    if verb.infinitive.hasSuffix("mobiliar") { return "-MOBILIAR" }
    if verb.infinitive.hasSuffix("gauchar") { return "-GAUCHAR" }
    
    for v in [ "baular", "ciumar", "inguar", "inquar", "prazer", "querer",
      "ruinar", "viuvar" ] {
        if verb.infinitive.hasSuffix(v) {
          return "-" + v.uppercaseString
        }
    }
    
    for v in [ "aguar", "aizar", "eizar", "eguar", "iguar", "iquar", "oibir",
      "oizar", "ouvir", "parir", "saber", "uizar" ] {
        if verb.infinitive.hasSuffix(v) {
          return "-" + v.uppercaseString
        }
    }
    
    // not sure if this should be in here
    for v in [ "quir", "qüir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    for v in [ "guar", "oiar", "quar"] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    for v in [ "car", "çar", "gar", "oar", "oer", "por" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // verb is regular
    for v in [ "ar", "er", "ir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // no match, should never ever happen
    return nil
  }
  
  
  /* Returns the conjugation type for this verb in the simple imperfect subjunctive tense.
     The result is valid for the simple future subjunctive tense as well. */
  private func getImperfectSubjunctiveVerbType() -> String? {
    if verb.darDerivative { return "-DAR" }
    if verb.estarDerivative { return "-ESTAR" }
    if verb.terDerivative { return "-TER" }
    if verb.verDerivative { return "-VER" }
    if verb.virDerivative { return "-VIR" }
    
    switch verb.infinitive {
    case "dar", "ensimesmar", "estar", "haver", "ir", "poder", "ser", "sobreir", "sobresser", "ter", "ver", "vir": return verb.infinitive.uppercaseString
    case "pôr": return "-POR"
    default: break
    }
    
    // start trying to match by suffix, from longer down to shorter, as longer is more specific
    if verb.infinitive.hasSuffix("querer") { return "-QUERER" }
    if verb.infinitive.hasSuffix("trazer") { return "-TRAZER" }
    
    for v in [ "caber", "dizer", "fazer", "saber" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    if verb.infinitive.hasSuffix("guir") || verb.infinitive.hasSuffix("güir") {
      return "-GUIR"
    }
    
    if verb.infinitive.hasSuffix("quir") || verb.infinitive.hasSuffix("qüir") {
      return "-QUIR"
    }
    
    for v in [ "aer", "air", "oer", "oir", "por", "uer", "uir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // verb is regular
    for v in [ "ar", "er", "ir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // no match, should never ever happen
    return nil
  }
  
  
  /* Returns the past participle type for this verb. */
  private func getPastParticipleVerbType() -> String? {
    if verb.verDerivative { return "-VER" }
    if verb.virDerivative { return "-VIR" }
    
    switch verb.infinitive {
    case "absolver", "aceitar", "acender", "anexar", "assentar", "benzer", "despertar", "dispersar", "distender", "distinguir", "eleger", "encher", "entregar", "envolver", "enxugar", "expressar", "exprimir", "expulsar", "extinguir", "fartar", "findar", "frigir", "ganhar", "gastar", "isentar", "juntar", "libertar", "limpar", "manifestar", "matar", "malquerer", "morrer", "murchar", "ocultar", "pagar", "pegar", "prender", "romper", "salvar", "secar", "segurar", "soltar", "sujeitar", "vagar", "ver", "vir": return verb.infinitive.uppercaseString
    case "pôr": return "-POR"
    default: break
    }
    
    // start trying to match by suffix, from longer down to shorter, as longer is more specific
    if verb.infinitive.hasSuffix("imprimir") { return "-IMPRIMIR" }
    if verb.infinitive.hasSuffix("screver") { return "-SCREVER" }
    
    for v in [ "abrir", "argir", "dizer", "ergir", "fazer" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    for v in [ "abrir", "argir", "dizer", "ergir", "fazer" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    if verb.infinitive.hasSuffix("guer") || verb.infinitive.hasSuffix("güer") {
      return "-GUER"
    }
    
    if verb.infinitive.hasSuffix("guir") || verb.infinitive.hasSuffix("güir") {
      return "-GUIR"
    }
    
    if verb.infinitive.hasSuffix("quer") || verb.infinitive.hasSuffix("qüer") {
      return "-QUER"
    }
    
    if verb.infinitive.hasSuffix("quir") || verb.infinitive.hasSuffix("qüir") {
      return "-QUIR"
    }
    
    for v in [ "aer", "air", "oer", "oir", "uir", "por" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // verb is regular
    for v in [ "ar", "er", "ir" ] {
      if verb.infinitive.hasSuffix(v) {
        return "-" + v.uppercaseString
      }
    }
    
    // no match, should never ever happen
    return nil
  }
  
  
  /* Returns the conjugation type for this verb in the given tense.
     Note: this function is only meant to be used with non-compound tenses.*/
  private func getVerbTypeFor(tense: Tense) -> String? {
    switch tense {
    case .PresentIndicative: return getPresentIndicativeVerbType()
    case .ImperfectIndicative: return getImperfectIndicativeVerbType()
    case .PreteriteIndicative, .PluperfectIndicative: return getPreteriteIndicativeVerbType()
    case .FutureIndicative, .Conditional: return getFutureIndicativeVerbType()
    case .PresentSubjunctive: return getPresentSubjunctiveVerbType()
    case .ImperfectSubjunctive, .FutureSubjunctive: return getImperfectSubjunctiveVerbType()
    case .PastParticiple: return getPastParticipleVerbType()
    default: return nil
    }
  }
  
  
  /* Returns an array of optional Strings containing the present indicative tense conjugations of the six 
     Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
     Person's conjugation that has no proper conjugated form will be nil. */
  func conjugatePresentIndicativeFor(variant: Variant) -> [String?] {
    
    // refresh the reusable variables
    resetSharedProperties()
    
    // determine which conjugation type class this verb belongs to for this tense
    let type = getVerbTypeFor(Tense.PresentIndicative)
    
    // by default, just use the regular stem with no adjustments for all 6 Persons
    stems = [Int](count: 6, repeatedValue: 1)
    
    // get the proper stem for this variant
    stem = verb.stemVariants[variant.rawValue]
    let len = stem.length()
    
    // store the proper endings for each Person for the regular verbs
    var ends = [String](count: 6, repeatedValue: "")
    let regAr = [ "o", "as", "a", "amos", "ais", "am" ]
    let regEr = [ "o", "es", "e", "emos", "eis", "em" ]
    let regIr = [ "o", "es", "e", "imos", "is", "em" ]
    
    switch verb.ending! {
    case "ar": ends = regAr
    case "er": ends = regEr
    case "ir": ends = regIr
    default: break;
    }
    
    // for each irregular conjugation type, modify the stem(s)/endings
    // the values stored in the stems array are explained at the end of the function
    switch type! {
    case "ABAIUCAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "ú")
      stems[0] = 14; stems[1] = 14; stems[2] = 14
      stems[5] = 14
    case "-ACUDIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "o")
      stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-AER":
      ends = [ "io", "is", "i", "emos", "eis", "em" ]
    case "AFIUZAR", "APAULAR", "AUNAR", "AVIUSAR", "AZIUMAR", "-BAULAR",
    "-CIUMAR", "DESEMBAULAR", "EMBAULAR", "ENVIUSAR", "FAULAR", "SAUDAR",
    "-VIUVAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "ú")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "AGENCIAR", "APRESENCIAR", "CADENCIAR", "COMERCIAR", "DESNEGOCIAR",
    "DESPREMIAR", "DILIGENCIAR", "LICENCIAR", "OBSEQUIAR", "-NEGOCIAR",
    "PREMIAR", "PRESENCIAR": // -iar verbs with two possible conjugations
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ei")
      stems[0] = 4; stems[1] = 4; stems[2] = 4
      stems[5] = 4
    case "-AGIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "j")
      stems[0] = 2
    case "-AGUAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "á")
      stems[0] = 22; stems[1] = 22; stems[2] = 22
      stems[5] = 22
    case "-AIR":
      ends = [ "io", "is", "i", "ímos", "ís", "em" ]
    case "-AIZAR", "-EIZAR", "-OIZAR", "-UIZAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "í")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "AJESUITAR", "RUIDAR", "-RUINAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "í")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-ANQUIR":
      stem2 = stem.substring(0, endIndex: len - 2) + "c"
      stems[0] = 2
    case "ANSIAR", "ARREMEDIAR", "DESARREMEDIAR", "DESREMEDIAR", "INCENDIAR",
    "INTERMEDIAR", "MEDIAR", "ODIAR", "PROMEDIAR": // irregular -iar verbs
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ei")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "APRAZER", "DESAPRAZER", "PRAZER", "-PRAZER":
      ends = [ "o", "es", "", "emos", "eis", "em" ]
    case "-ARGUIR", "-ARGÜIR": // takes care of u with treme for bpNoAO
      ends = [ "o", "is", "i", "imos", "is", "em" ]
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ü")
      stem3 = replaceCharacterFromEnd(1, inString: stem, with: "ú")
      stem4 = replaceCharacterFromEnd(1, inString: stem, with: "u")
      stems[0] = 31; stems[1] = 20; stems[2] = 20
      stems[3] = 16; stems[4] = 16; stems[5] = 20
    case "ASPERGIR", "CONVERGIR", "DIVERGIR":
      stem2 = stem.substring(0, endIndex: len - 3) + "irj"
      stems[0] = 2
    case "ATEIZAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "í")
      stems[0] = 10; stems[1] = 10; stems[2] = 10
      stems[5] = 10
    case "-BALAUSTRAR":
      stem2 = replaceCharacterFromEnd(4, inString: stem, with: "ú")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-CABER":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "ai")
      stems[0] = 2
    case "-CER":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ç")
      stems[0] = 2
      break;
    case "CERZIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "i")
      stems[1] = 4; stems[2] = 4
      stems[5] = 4
    case "-CIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ç")
      stems[0] = 2
    case "-COBRIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "u")
      stems[0] = 2
    case "-CONSTRUIR", "DESTRUIR":
      ends = [ "o", "is", "i", "ímos", "ís", "em" ]
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ó")
      stems[1] = 4; stems[2] = 4
      stems[5] = 4
    case "CONSUMIR", "SUBIR", "SUMIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "o")
      stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "CRER", "DESCRER", "LER", "-LER", "RER":
      ends = [ "io", "s", "", "mos", "des", "em" ]
      stem2 = stem + "e"
      stem3 = stem + "ê"
      stems[0] = 2; stems[1] = 3; stems[2] = 3
      stems[3] = 2; stems[4] = 2; stems[5] = 7
    case "-CUSPIR", "-GUSPIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "o")
      stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "DAR", "-DAR":
      ends = [ "ou", "ás", "á", "amos", "ais", "ão" ]
    case "-DELINQUIR":
        stem2 = stem.substring(0, endIndex: stem.length() - 4);
        // need special behavior for this very unique verb
        // sadly, the compiler bitches if we use the commented out code below
        var temp: String
        var temp2: String
        temp = stem2 + "inquo/"
        temp2 = stem2 + "ínquo"
        bpWithAO[0] = temp + temp2
        temp = stem2 + "inquis/"
        temp2 = stem2 + "ínques"
        bpWithAO[1] = temp + temp2
        temp = stem2 + "inqui/"
        temp2 = stem2 + "ínque"
        bpWithAO[2] = temp + temp2
        bpWithAO[3] = stem2 + "inquimos"
        bpWithAO[4] = stem2 + "inquis"
        temp = stem2 + "inquem/"
        temp2 = stem2 + "ínquem"
        bpWithAO[5] = temp + temp2
        
        /*
        bpWithAO = [ stem2 + "inquo/" + stem2 + "ínquo",
        stem2 + "inquis/" + stem2 + "ínques",
        stem2 + "inqui/" + stem2 + "ínque",
        stem2 + "inquimos", stem2 + "inquis", stem2 + "inquem/" +
        stem2 + "ínquem" ]
        */
        
        bpWithoutAO = [ nil, stem2 + "ínqües", stem2 + "ínqüe",
            stem2 + "inqüimos", stem2 + "inqüis", stem2 + "ínqüem" ]
        
        temp = stem2 + "inquo/"
        temp2 = stem2 + "ínquo"
        epWithAO[0] = temp + temp2
        temp = stem2 + "inquis/"
        temp2 = stem2 + "ínques"
        epWithAO[1] = temp + temp2
        temp = stem2 + "inqui/"
        temp2 = stem2 + "ínque"
        epWithAO[2] = temp + temp2
        epWithAO[3] = stem2 + "inquimos"
        epWithAO[4] = stem2 + "inquis"
        temp = stem2 + "inquem/"
        temp2 = stem2 + "ínquem"
        epWithAO[5] = temp + temp2
        
        /*
        epWithAO = [ stem2 + "inquo/" + stem2 + "ínquo",
        stem2 + "inquis/" + stem2 + "ínques",
        stem2 + "inqui/" + stem2 + "ínque",
        stem2 + "inquimos", stem2 + "inquis", stem2 + "inquem/" + stem2 +
        "ínquem" ]
        */
        
        temp = stem2 + "inquo/"
        temp2 = stem2 + "ínquo"
        epWithoutAO[0] = temp + temp2
        temp = stem2 + "inqüis/"
        temp2 = stem2 + "ínques"
        epWithoutAO[1] = temp + temp2
        temp = stem2 + "inqüi/"
        temp2 = stem2 + "ínque"
        epWithoutAO[2] = temp + temp2
        epWithoutAO[3] = stem2 + "inquimos"
        epWithoutAO[4] = stem2 + "inquis"
        temp = stem2 + "inqüem/"
        temp2 = stem2 + "ínquem"
        epWithoutAO[5] = temp + temp2
        
        /*
        epWithoutAO = [ stem2 + "inquo/" + stem2 + "ínquo",
        stem2 + "inqüis/" + stem2 + "ínques",
        stem2 + "inqüi/" + stem2 + "ínque",
        stem2 + "inquimos", stem2 + "inquis",
        stem2 + "inqüem/" + stem2 + "ínquem" ]
        */
        
        stems = [ 19, 19, 19, 19, 19, 19 ]
    case "DENEGRIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "i")
      stems[0] = 2; stems[1] = 2; stems[2] = 2;
      stems[5] = 2;
    case "DESMILINGUIR":
      bpWithAO = [ "desmilínguo", "desmilíngues", "desmilíngue",
        "desmilínguimos", "desmilínguis", "desmilínguem" ]
      bpWithoutAO = [ "desmilínguo", "desmilíngües", "desmilíngüe",
        "desmilíngüimos","desmilíngüis", "desmilíngüem" ]
      epWithAO = [ "desmilinguo", "desmilingúis",
        "desmilingúi", "desmilinguimos", "desmilinguis",
        "desmilingúem" ]
      epWithoutAO = [ "desmilinguo", "desmilingúis",
        "desmilingúi", "desmilinguimos", "desmilinguis",
        "desmilingúem" ]
      stems = [ 19, 19, 19, 19, 19, 19 ]
    case "-DIZER":
      ends = [ "o", "es", "", "emos", "eis", "em" ]
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "g")
      stems[0] = 2
    case "-DORMIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "u")
      stems[0] = 2
    case "-EAR":
      stem2 = stem + "i"
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-ECTIR", "-ERTIR", "-ESPIR", "-ESTIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "i")
      stems[0] = 2
    case "-EDIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "i")
      stems[0] = 2
    case "-EGER":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "j")
      stems[0] = 2
    case "-EGUAR": // verify
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "é")
      stems[0] = 29; stems[1] = 29; stems[2] = 29
      stems[5] = 29
    case "-EGUIR":
      stem2 = stem.substring(0, endIndex: len - 3) + "ig"
      stems[0] = 2
    case "-EGÜIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "u")
      stem2 = replaceCharacterFromEnd(3, inString: stem2, with: "i")
      stems[0] = 2
    case "-ELIR", "-EMIR", "-ENIR", "-ERIR", "-ETIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "i")
      stems[0] = 2
    case "-EMBAIR": // irregular defective
      ends = [ "io", "es", "e", "ímos", "ís", "em" ]
    case "EMBAUCAR", "ESMIUÇAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "ú")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-ENGOLIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "u")
      stems[0] = 2
    case "-ENHIR", "-ENTIR", "-ERVIR", "-ERZIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "i")
      stems[0] = 2
    case "ENSIMESMAR":
      bpWithAO = [ "ensimesmo/enmimmesmo",
        "ensimesmas/entimesmas", "ensimesma", "ensimesmamos/ennosmesmamos",
        "ensimesmais/envosmesmais", "ensimesmam" ]
      bpWithoutAO = [ "ensimesmo/enmimmesmo",
        "ensimesmas/entimesmas", "ensimesma", "ensimesmamos/ennosmesmamos",
        "ensimesmais/envosmesmais", "ensimesmam" ]
      epWithAO = [ "ensimesmo/enmimmesmo",
        "ensimesmas/entimesmas", "ensimesma", "ensimesmamos/ennosmesmamos",
        "ensimesmais/envosmesmais", "ensimesmam" ]
      epWithoutAO = [ "ensimesmo/enmimmesmo",
        "ensimesmas/entimesmas", "ensimesma", "ensimesmamos/ennosmesmamos",
        "ensimesmais/envosmesmais", "ensimesmam" ]
      stems = [ 19, 19, 19, 19, 19, 19 ]
    case "-ENTUPIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "o")
      stems[1] = 4; stems[2] = 4
      stems[5] = 4
    case "-EQUAR":  // both forms in br perhaps?
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "é")
      stems[0] = 15; stems[1] = 15; stems[2] = 15
      stems[5] = 15
    case "-ERGIR":
      stem2 = stem.substring(0, endIndex: len - 3) + "irj"
      stem3 = replaceCharacterFromEnd(1, inString: stem, with: "j")
      stems[0] = 5 // both??
    case "-ERGUER":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "")
      stems[0] = 2
    case "-ERNIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "i")
      stems[0] = 2
    case "ESTAR", "-ESTAR":
      ends = [ "ou", "ás", "á", "amos", "ais", "ão" ]
    case "EXPLODIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "u")
      stems[0] = 4
    case "FAISCAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "í")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-FAZER":
      ends = [ "o", "es", "", "emos", "eis", "em" ]
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ç")
      stems[0] = 2
    case "FRIGIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "j")
      stem3 = replaceCharacterFromEnd(2, inString: stem, with: "e")
      stems[0] = 2; stems[1] = 3; stems[2] = 3
      stems[5] = 3
    case "FUGIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "j")
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "o")
      stems[0] = 2; stems[1] = 3; stems[2] = 3
      stems[5] = 3
    case "-GAUCHAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "ú")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-GER", "-GIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "j")
      stems[0] = 2
    case "-GREDIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "i")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-GÜER":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "u")
      stems[0] = 2
    case "-GUIR": // perhaps split this to "-GÜIR" too
      let last2 = verb.infinitive.substring(verb.infinitive.length() - 4, endIndex: verb.infinitive.length() - 2)
      if last2 == "gü" {
        stem2 = stem
      } else {
        stem2 = replaceCharacterFromEnd(1, inString: stem, with: "")
      }
      stems[0] = 2
    case "-GÜIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "u")
      stems[0] = 2
    case "-GUIZAR", "-QUIZAR":
      // regular -ar verb as 'u' is silent
      break
    case "HAVER":
      ends = [ "ei", "ás", "á", "emos", "eis", "ão" ]
      stem2 = stem.substring(0, endIndex: len - 2)
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[3] = 4; stems[4] = 4; stems[5] = 2
    case "-IGUAR", "-IQUAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "í")
      stems[0] = 15; stems[1] = 15; stems[2] = 15
      stems[5] = 15
    case "-INGUAR", "-INQUAR":
      stem2 = replaceCharacterFromEnd(4, inString: stem, with: "í")
      stems[0] = 4; stems[1] = 4; stems[2] = 4
      stems[5] = 4
    case "IR", "SOBREIR":
      ends = [ "vou", "vás", "vá", "vamos", "ides", "vão" ]
    case "-JAZER":
      ends = [ "o", "es", "", "emos", "eis", "em" ]
    case "-MEDIR", "-PEDIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ç")
      stems[0] = 2
    case "-MOBILIAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "í")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-OAR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ô")
      stems[0] = 16
    case "-OER":
      ends = [ "o", "is", "i", "emos", "eis", "em" ]
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ô")
      stem3 = replaceCharacterFromEnd(1, inString: stem, with: "ó")
      stems[0] = 16; stems[1] = 3; stems[2] = 3
    case "-OIAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "ó")
      stems[0] = 13; stems[1] = 13; stems[2] = 13
      stems[5] = 13
    case "-OIBIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "í")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-OUVIR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ç")
      stem3 = replaceCharacterFromEnd(2, inString: stem2, with: "i")
      stems[0] = 5
    case "PARAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "á")
      stems[2] = 13
    case "-PARIR": // needs more research
      stem2 = stem
      stem = replaceCharacterFromEnd(1, inString: stem, with: "ir")
      stems[0] = 4
    case "-PERDER":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "c")
      stems[0] = 2
    case "-PODER":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ss")
      stems[0] = 2
    case "-POLIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "u")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "PÔR", "-POR":
      ends = [ "onho", "ões", "õe", "omos", "ondes", "õem" ]
    case "PUITAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "í")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-QUERER":
      ends = [ "o", "es", "e", "emos", "eis", "em" ]
      stem2 = stem + "/" + stem
      stems[2] = 2
    case "-QUIR", "-QÜIR":
      stems[0] = 0
    case "REQUERER":
      ends = [ "o", "es", "e", "emos", "eis", "em" ]
      stem2 = stem + "/" + stem
      stem3 = replaceCharacterFromEnd(2, inString: stem, with: "ei")
      stems[0] = 3; stems[2] = 2
    case "RETORQUIR":
      //stem2 = chCharToLast(1, stem, uTreme);
      //stem3 = chCharToLast(4, stem2, oAcute);
      stems[0] = 0
      //stems[1] = 17; stems[2] = 17;
      //stems[3] = 18; stems[4] = 18; stems[5] = 17;
    case "RETORQÜIR":
      stem2 = replaceCharacterFromEnd(4, inString: stem, with: "ó")
      stems[0] = 0; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "REUNIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "ú")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "RIR", "-SORRIR":
      ends = [ "io", "is", "i", "imos", "ides", "iem" ]
    case "-SABER":
      ends = [ "ei", "es", "e", "emos", "eis", "em" ]
      stem2 = stem.substring(0, endIndex: len - 2);
      stems[0] = 2
    case "SER":
      ends = [ "ou", "és", "é", "omos", "ois", "ão" ]
      stem2 = stem.substring(0, endIndex: len - 1);
      stems[1] = 2; stems[2] = 2
    case "SOBRESSER": // two 's' situation
      ends = [ "ou", "és", "é", "omos", "ois", "ão" ]
      stem2 = stem.substring(0, endIndex: len - 2);
      stems[1] = 2; stems[2] = 2
    case "SORTIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "u")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "TER":
      ends = [ "enho", "ens", "em", "emos", "endes", "êm" ]
    case "-TER":
      ends = [ "enho", "éns", "ém", "emos", "endes", "êm" ]
    case "TOSSIR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "u")
      stems[0] = 2
    case "-TRAZER":
      ends = [ "o", "es", "", "emos", "eis", "em" ]
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "g")
      stems[0] = 2
    case "-UIR":
      ends = [ "o", "is", "i", "ímos", "ís", "em" ]
    case "-ULIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "o")
      stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-UZIR":
      ends = [ "o", "es", "", "imos", "eis", "em" ]
    case "-VALER":
      ends = [ "o", "es", "e", "emos", "eis", "em" ]
      stem2 = stem + "h"
      stems[0] = 2
    case "VER", "-VER":
      ends = [ "jo", "s", "", "mos", "des", "em" ]
      stem2 = stem + "e"
      stem3 = stem + "ê";
      stems[0] = 2; stems[1] = 3; stems[2] = 3
      stems[3] = 2; stems[4] = 2; stems[5] = 7
    case "VIR":
      ends = [ "enho", "ens", "em", "imos", "indes", "êm" ]
    case "-VIR":
      ends = [ "enho", "éns", "ém", "imos", "indes", "êm" ]
    default: // regular verbs
      break
    }
    
    // for verbs lacking conjugated forms for certain Persons,
    // mark them
    if verb.firstPersonSingularOnly {
      stems[0] = 0
    } else if verb.arrhizotonicFormsOnly {
      stems[0] = 0; stems[1] = 0; stems[2] = 0
      stems[5] = 0
    } else if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0
      stems[3] = 0; stems[4] = 0; stems[5] = 0
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0
      stems[3] = 0; stems[4] = 0
    }
    
    // attach the correct stems with the correct endings for each
    // conjugated form
    
    // couldn't find any efficient way to code this other than to
    // do all 4 Variants each time this function runs
    for var i = 0; i < 6; i++ {
      switch stems[i] {
      case 0:
        bpWithAO[i] = nil
        bpWithoutAO[i] = nil
        epWithAO[i] = nil
        epWithoutAO[i] = nil
      case 1:
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 2:
        bpWithAO[i] = stem2 + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem2 + ends[i]
        epWithoutAO[i] = stem2 + ends[i]
      case 3:
        bpWithAO[i] = stem3 + ends[i]
        bpWithoutAO[i] = stem3 + ends[i]
        epWithAO[i] = stem3 + ends[i]
        epWithoutAO[i] = stem3 + ends[i]
      case 4: // use stems "stem" and "stem2" both
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
      case 5: // use stems "stem2" and "stem3" both
        bpWithAO[i] = stem2 + ends[i] + "/" + stem3 + ends[i]
        bpWithoutAO[i] = stem2 + ends[i] + "/" + stem3 + ends[i]
        epWithAO[i] = stem2 + ends[i] + "/" + stem3 + ends[i]
        epWithoutAO[i] = stem2 + ends[i] + "/" + stem3 + ends[i]
      case 7: // use "stem3" for epWithoutAO and bpWithoutAO,
        // and "stem2" for epWithAO and bpWithAO
        bpWithAO[i] = stem2 + ends[i]
        bpWithoutAO[i] = stem3 + ends[i]
        epWithAO[i] = stem2 + ends[i]
        epWithoutAO[i] = stem3 + ends[i]
      case 10: // different stem between bp and ep
        bpWithAO[i] = stem2 + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 13: // use "stem2" for epWithoutAO and bpWithoutAO,
        // and "stem" for epWithAO and bpWithAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem2 + ends[i]
      case 14: // use "stem2" for ep and bpWithoutAO,
        // and "stem" for bpWithAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem2 + ends[i]
        epWithoutAO[i] = stem2 + ends[i]
      case 15: // use stems "stem" and "stem2" both in bp
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 16: // use "stem" for ep and bpWithAO,
        // and "stem2" for bpWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 17: // use "stem" for ep and bpWithAO,
        // and both "stem" and "stem2" for bpWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 18: // use "stem" for ep and bpWithAO,
        // and both "stem" and "stem3" for bpWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem + ends[i] + "/" + stem3 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 20: // use "stem3" for epWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem3 + ends[i]
      case 22: // use both "stem" and "stem2" for epWithAO and bpWithAO,
        // and "stem2" for bpWithoutAO
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 23: // use "stem" for ep and bpWithAO,
        // and "stem3" for bpWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem3 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 29: // use stems "stem" and "stem2" both in bpWithAO
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 31:
        bpWithAO[i] = stem4 + ends[i]
        bpWithoutAO[i] = stem4 + ends[i]
        epWithAO[i] = stem4 + ends[i]
        epWithoutAO[i] = stem4 + ends[i]
      default: break // do absolutely nothing (delinquir/ensimesmar)
      }
    }
    
    // only return the conjugation set matching the given Variant
    if variant == Variant.BPWithAccord {
      return bpWithAO;
    } else if variant == Variant.BPWithoutAccord {
      return bpWithoutAO;
    } else if variant == Variant.EPWithAccord {
      return epWithAO;
    } else {
      return epWithoutAO;
    }
  }
  
  
  /* Returns an array of optional Strings containing the imperfect indicative tense conjugations of the six
  Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugateImperfectIndicativeFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.ImperfectIndicative)
    var stem = verb.stemVariants[variant.rawValue]
    let len = stem.length()
    
    var ends = [String](count: 6, repeatedValue: "")
    let regAr = [ "ava", "avas", "ava", "ávamos", "áveis", "avam" ]
    let regEr = [ "ia", "ias", "ia", "íamos", "íeis", "iam" ]
    let regIr = [ "ia", "ias", "ia", "íamos", "íeis", "iam" ]
    
    switch verb.ending! {
    case "ar":
      ends = regAr
    case "er":
      ends = regEr
    case "ir":
      ends = regIr
    default:
      break;
    }
    
    switch type! {
    case "-AER", "-AIR", "-OER", "-OIR", "-UER", "-UIR":
      ends = [ "ía", "ías", "ía", "íamos", "íeis", "íam" ]
    case "ENSIMESMAR":
      return [ "ensimesmava/enmimmesmava", "ensimesmavas/entimesmavas", "ensimesmava", "ensimesmávamos/ennosmesmávamos", "ensimesmáveis/envosmesmáveis", "ensimesmavam" ]
    case "-GUER", "-GUIR", "-QUIR": break
    case "-POR":
      ends = [ "unha", "unhas", "unha", "únhamos", "únheis", "unham" ]
    case "SER":
      stem = ""
      ends = [ "era", "eras", "era", "éramos", "éreis", "eram" ]
    case "SOBRESSER":
      stem = "sobre"
      ends = [ "era", "eras", "era", "éramos", "éreis", "eram" ]
    case "TER", "-TER", "VIR", "-VIR":
      ends = [ "inha", "inhas", "inha", "ínhamos", "ínheis", "inham" ]
    default: break
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
  
    // this tense is easy, only some endings change
    var conjugations = [String?](count: 6, repeatedValue: nil)
    for var i = 0; i < 6; i++ {
      if stems[i] != 0 { conjugations[i] = stem + ends[i] }
    }
    
    return conjugations
  }
  
  
  /* Returns an array of optional Strings containing the preterite perfect indicative tense conjugations
  of the six Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugatePreteriteIndicativeFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.PreteriteIndicative)
    var stem = verb.stemVariants[variant.rawValue]
    let len = stem.length()
    
    var ends = [String](count: 6, repeatedValue: "")
    let regAr = [ "ei", "aste", "ou", "amos", "astes", "aram" ]
    let regEr = [ "i", "este", "eu", "emos", "estes", "eram" ]
    let regIr = [ "i", "iste", "iu", "imos", "istes", "iram" ]
    
    switch verb.ending! {
    case "ar":
      ends = regAr
    case "er":
      ends = regEr
    case "ir":
      ends = regIr
    default:
      break;
    }
    
    switch type! {
    case "-AER", "-OER":
      ends = [ "í", "este", "eu", "emos", "estes", "eram" ]
    case "-AIR", "-UIR":
      ends = [ "í", "íste", "iu", "ímos", "ístes", "íram" ]
    case "-ABER":
      ends = [ "e", "este", "e", "emos", "estes", "eram" ]
      stem = stem.substring(0, endIndex: len - 2) + "oub"
    case "-CAR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "qu")
      stems[0] = 2
    case "-ÇAR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "c")
      stems[0] = 2
    case "DAR", "-DAR":
      ends = [ "ei", "este", "eu", "emos", "estes", "eram" ]
    case "-DIZER":
      ends = [ "e", "este", "e", "emos", "estes", "eram" ]
      stem = replaceCharacterFromEnd(1, inString: stem, with: "ss")
    case "ENSIMESMAR":
      switch variant {
      case .BPWithAccord, .BPWithoutAccord: return [ "ensimesmei/enmimmesmei", "ensimesmaste/entimesmaste", "ensimesmou", "ensimesmamos/ennosmesmamos", "ensimesmastes/envosmesmastes", "ensimesmaram" ]
      case .EPWithAccord: return [ "ensimesmei/enmimmesmei", "ensimesmaste/entimesmaste", "ensimesmou", "ensimesmámos/ensimesmamos/ennosmesmámos/ennosmesmamos", "ensimesmastes/envosmesmastes", "ensimesmaram" ]
      case .EPWithoutAccord: return [ "ensimesmei/enmimmesmei", "ensimesmaste/entimesmaste", "ensimesmou", "ensimesmámos/ennosmesmámos", "ensimesmastes/envosmesmastes", "ensimesmaram" ]
      }
    case "ESTAR", "-ESTAR":
      ends = [ "e", "este", "e", "emos", "estes", "eram" ]
      stem = stem + "iv"
    case "-FAZER":
      ends = [ "iz", "izeste", "ez", "izemos", "izestes", "izeram" ]
      stem = stem.substring(0, endIndex: len - 2)
    case "-GAR":
      stem2 = stem + "u"
      stems[0] = 2
    case "-GUAR", "-QUAR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ü")
      stems[0] = 16
    case "-GUIR", "-QUIR": break
    case "HAVER", "REAVER":
      ends = [ "e", "este", "e", "emos", "estes", "eram" ]
      stem = stem.substring(0, endIndex: len - 2) + "ouv";
    case "IR", "SOBREIR":
      ends = [ "fui", "foste", "foi", "fomos", "fostes", "foram" ]
    case "QUERER":
      ends = [ "", "este", "", "emos", "estes", "eram" ]
      stem = stem.substring(0, endIndex: len - 2) + "is"
    case "PODER":
      ends = [ "ude", "udeste", "ôde", "udemos", "udestes", "uderam" ]
      stem = stem.substring(0, endIndex: len - 2)
    case "-POR":
      ends = [ "us", "useste", "ôs", "usemos", "usestes", "useram" ]
    case "-PRAZER":
      // ends has 12 elements for this verb type
      // requires special treatment at end of function
      ends = [ "e", "este", "e", "emos", "estes", "eram",
        "i", "este", "eu", "emos", "estes", "eram" ]
      stem2 = stem.substring(0, endIndex: len - 2) + "ouv"
      stems = [Int](count: 6, repeatedValue: 24)
    case "REQUERER": break
    case "SER":
      ends = [ "fui", "foste", "foi", "fomos", "fostes", "foram" ]
      stem = ""
    case "SOBRESSER":
      ends = [ "fui", "foste", "foi", "fomos", "fostes", "foram" ]
      stem = stem.substring(0, endIndex: len - 2)
    case "TER", "-TER":
      ends = [ "ive", "iveste", "eve", "ivemos", "ivestes", "iveram" ]
    case "-TRAZER":
      ends = [ "e", "este", "e", "emos", "estes", "eram" ]
      stem = stem.substring(0, endIndex: len - 2) + "oux"
    case "VER", "-VER":
      ends = [ "i", "iste", "iu", "imos", "istes", "iram" ]
    case "VIR", "-VIR":
      ends = [ "im", "ieste", "eio", "iemos", "iestes", "ieram" ]
    default: break
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
    
    // European Portuguese has two ending forms for the 1pp Person's conjugation
    if (variant == Variant.EPWithAccord || variant == Variant.EPWithoutAccord) && ends[3] == "amos" {
      ends[3] = "ámos"
    }
    
    for var i = 0; i < 6; i++ {
      switch stems[i] {
      case 0:
        bpWithAO[i] = nil
        bpWithoutAO[i] = nil
        epWithAO[i] = nil
        epWithoutAO[i] = nil
      case 1:
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 2:
        bpWithAO[i] = stem2 + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem2 + ends[i]
        epWithoutAO[i] = stem2 + ends[i]
      case 16: // use "stem" for ep and bpWithAO,
        // and "stem2" for bpWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 24: // for -prazer
        bpWithAO[i] = stem2 + ends[i] + "/" + stem + ends[i + 6]
        bpWithoutAO[i] = stem2 + ends[i] + "/" + stem + ends[i + 6]
        epWithAO[i] = stem2 + ends[i] + "/" + stem + ends[i + 6]
        epWithoutAO[i] = stem2 + ends[i] + "/" + stem + ends[i + 6]
      default: break // do absolutely nothing
      }
    }
    
    if variant == Variant.BPWithAccord {
      return bpWithAO;
    } else if variant == Variant.BPWithoutAccord {
      return bpWithoutAO;
    } else if variant == Variant.EPWithAccord {
      // two separate forms for EP post AO
      if let firstPersonPlural = epWithAO[3] {
        if firstPersonPlural.substring(firstPersonPlural.length() - 4) == "ámos" {
          epWithAO[3] = epWithAO[3]! + "/" + replaceCharacterFromEnd(4, inString: firstPersonPlural, with: "a")
        }
      }
      return epWithAO;
    } else {
      return epWithoutAO;
    }
  }
  
  
  /* Returns an array of optional Strings containing the pluperfect tense conjugations of the six
  Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugatePluperfectIndicativeFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.PluperfectIndicative)
    // pluperfect uses same stems as the preterite perfect indicative
    stem = getConjugatedForm(conjTable, tense: Tense.PreteriteIndicative, person: Person.ThirdPersonPlural, variant: variant)
    stem = stem.substring(0, endIndex: stem.length() - 4)
    let len = stem.length()
    
    var ends = [String](count: 6, repeatedValue: "")
    let regAr = [ "ara", "aras", "ara", "áramos", "áreis", "aram" ]
    let regEr = [ "era", "eras", "era", "êramos", "êreis", "eram" ]
    let regIr = [ "ira", "iras", "ira", "íramos", "íreis", "iram" ]
    
    switch verb.ending! {
    case "ar":
      ends = regAr
    case "er":
      ends = regEr
    case "ir":
      ends = regIr
    default:
      break;
    }
    
    switch type! {
    case "-ABER", "DAR", "-DAR", "-DIZER", "ESTAR", "-ESTAR", "-FAZER", "HAVER", "PODER", "-POR", "-QUERER", "TER", "-TER", "-TRAZER", "VIR", "-VIR":
      ends = [ "era", "eras", "era", "éramos", "éreis", "eram" ]
    case "-AIR", "-UIR":
      ends = [ "íra", "íras", "íra", "íramos", "íreis", "íram" ]
    case "ENSIMESMAR":
      return [ "ensimesmara/enmimmesmara", "ensimesmaras/entimesmaras", "ensimesmara", "ensimesmáramos/ennosmesmáramos", "ensimesmáreis/envosmesmáreis", "ensimesmaram" ]
    case "-GUIR", "-QUIR": break   // unnecessary, I believe
    case "IR", "SER", "SOBREIR", "SOBRESSER":
      ends = [ "ora", "oras", "ora", "ôramos", "ôreis", "oram" ]
    case "-PRAZER":
      ends = [ "era", "eras", "era", "éramos", "éreis", "eram" ]
      stem2 = verb.stemVariants[variant.rawValue]
      stem = stem2.substring(0, endIndex: stem2.length() - 2) + "ouv";
      stems = [Int](count: 6, repeatedValue: 4)
    case "VER", "-VER":
      ends = [ "ira", "iras", "ira", "íramos", "íreis", "iram" ]
    default: break
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
    
    for var i = 0; i < 6; i++ {
      switch stems[i] {
      case 0:
        bpWithAO[i] = nil
        bpWithoutAO[i] = nil
        epWithAO[i] = nil
        epWithoutAO[i] = nil
      case 1:
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 4: // use stems "stem" and "stem2" both
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
      default: break // do absolutely nothing
      }
    }
    
    if variant == Variant.BPWithAccord {
      return bpWithAO;
    } else if variant == Variant.BPWithoutAccord {
      return bpWithoutAO;
    } else if variant == Variant.EPWithAccord {
      return epWithAO;
    } else {
      return epWithoutAO;
    }
  }
  
  
  /* Returns an array of optional Strings containing the future indicative tense conjugations of the six
  Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugateFutureIndicativeFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.FutureIndicative)
    var stem = verb.infinitiveVariants[variant.rawValue]
    let len = stem.length()
    
    // all verbs have same endings in future tense
    ends = [ "ei", "ás", "á", "emos", "eis", "ão" ]
    
    switch type! {
    case "-DIZER", "-FAZER", "-TRAZER":
      stem = stem.substring(0, endIndex: len - 3) + "r"
    case "ENSIMESMAR":
      return [ "ensimesmarei/enmimmesmarei", "ensimesmarás/entimesmarás", "ensimesmará", "ensimesmaremos/ennosmesmaremos", "ensimesmareis/envosmesmareis", "ensimesmarão" ]
    case "PÔR":
      stem = "por"
    default: break
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
    
    var conjugations = [String?](count: 6, repeatedValue: nil)
    for var i = 0; i < 6; i++ {
      if stems[i] != 0 { conjugations[i] = stem + ends[i]! }
    }
    
    return conjugations
  }
  
  
  /* Returns an array of optional Strings containing the conditional tense conjugations of the six
  Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugateConditionalFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.Conditional)
    var stem = verb.infinitiveVariants[variant.rawValue]
    let len = stem.length()
    
    // all verbs have same endings in conditional tense
    ends = [ "ia", "ias", "ia", "íamos", "íeis", "iam" ]
    
    switch type! {
    case "-DIZER", "-FAZER", "-TRAZER":
      stem = stem.substring(0, endIndex: len - 3) + "r"
    case "ENSIMESMAR":
      return [ "ensimesmaria/enmimmesmaria", "ensimesmarias/entimesmarias", "ensimesmaria", "ensimesmaríamos/ennosmesmaríamos", "ensimesmaríeis/envosmesmaríeis", "ensimesmariam" ]
    case "PÔR":
      stem = "por"
    default: break
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
    
    var conjugations = [String?](count: 6, repeatedValue: nil)
    for var i = 0; i < 6; i++ {
      if stems[i] != 0 { conjugations[i] = stem + ends[i]! }
    }
    
    return conjugations
  }
  
  
  /* Returns an array of optional Strings containing the present subjunctive tense conjugations of the six
  Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugatePresentSubjunctiveFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.PresentSubjunctive)
    stems = [Int](count: 6, repeatedValue: 1)
    
    // the default stem is derived from the 1ps form of the verb in the present indicative tense
    stem = getConjugatedForm(conjTable, tense: Tense.PresentIndicative, person: Person.FirstPersonSingular, variant: variant)
    
    var ends = [String](count: 6, repeatedValue: "")
    let regAr = [ "e", "es", "e", "emos", "eis", "em" ]
    let regEr = [ "a", "as", "a", "amos", "ais", "am" ]
    let regIr = regEr
    
    switch verb.ending! {
    case "ar": ends = regAr
    case "er": ends = regEr
    case "ir": ends = regIr
    default: break
    }
    
    // if the verb is defective, there is no conjugation in the present subjunctive tense
    // if the verb is conjugated in only the third person, we derive a generic stem by removing the ending
    // of the infinitive
    if stem == nil {
      if verb.arrhizotonicFormsOnly || verb.firstPersonSingularOnly || type == "-QUIR" || type == "-QÜIR" || type == "-DELINQUIR" {
        return [String?](count: 6, repeatedValue: nil)
      }
      stem = verb.infinitiveVariants[variant.rawValue]
      stem = stem.substring(0, endIndex: stem.length() - 2)
    }
    // the first person singular of the present indicative tense has two forms, so we get two stems
    else if stem.rangeOfString("/") != nil {
      let slashIndex = stem.rangeOfString("/")!.startIndex
      stem2 = stem.substringWithRange(slashIndex.advancedBy(1)...stem.endIndex.advancedBy(-2))
      stem = stem.substringWithRange(stem.startIndex...slashIndex.advancedBy(-2))
      stems = [ 4, 4, 4, 1, 1, 4 ]
    } else {
      stem = stem.substring(0, endIndex: stem.length() - 1)
    }
    let len = stem.length()
    
    // who doesn't love the treme ¨?
    if variant == Variant.BPWithoutAccord && (verb.infinitive.hasSuffix("guar") || verb.infinitive.hasSuffix("quar")) {
      stem = replaceCharacterFromEnd(1, inString: stem, with: "ü")
    }
    
    // except in the case of verbs with two forms in the present tense indicative 1pp, we will by default
    // just attach the standard endings to the stem
    // this switch block allows this default to be changed for irregular verb conjugation types
    switch type! {
    case "ABAIUCAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "u")
      stem = replaceCharacterFromEnd(1, inString: stem, with: "qu")
      stems[3] = 2; stems[4] = 2
    case "AFIUZAR", "APAULAR", "AUNAR", "AVIUSAR", "AZIUMAR", "-BAULAR", "-CIUMAR", "DESEMBAULAR", "EMBAULAR", "ENVIUSAR", "FAULAR", "SAUDAR", "-VIUVAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "u")
      stems[3] = 2; stems[4] = 2
    case "-AGUAR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ú")
      stem3 = replaceCharacterFromEnd(1, inString: stem, with: "ü")
      stem4 = replaceCharacterFromEnd(3, inString: stem3, with: "a")
      stems[3] = 26; stems[4] = 26
    case "-AIZAR", "-EIZAR", "-OIZAR", "-UIZAR", "AJESUITAR", "ATEIZAR", "RUIDAR", "-RUINAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "i")
      stems[3] = 2; stems[4] = 2
    case "ANSIAR", "ARREMEDIAR", "DESARREMEDIAR", "DESREMEDIAR", "INCENDIAR", "INTERMEDIAR", "MEDIAR", "ODIAR", "PROMEDIAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "")
      stems[3] = 2; stems[4] = 2
    case "-BALAUSTRAR":
      stem2 = replaceCharacterFromEnd(4, inString: stem, with: "u")
      stems[3] = 2; stems[4] = 2
    case "-CAR":
      stem = replaceCharacterFromEnd(1, inString: stem, with: "qu")
    case "-ÇAR":
      stem = replaceCharacterFromEnd(1, inString: stem, with: "c")
    case "DAR", "-DAR":
      ends = [ "", "s", "", "mos", "is", "em" ]
      stem = stem.substring(0, endIndex: len - 1)
      stem2 = stem + "ê"
      stem = stem + "e"
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[3] = 4; stems[5] = 13
    case "-DELINQUIR":
      stems[3] = 1; stems[4] = 1
    case "DESMILINGUIR":
      stem = replaceCharacterFromEnd(4, inString: stem, with: "i")
    case "-EGUAR":
      stem3 = replaceCharacterFromEnd(3, inString: stem, with: "e")
      stem4 = replaceCharacterFromEnd(1, inString: stem3, with: "ú")
      stems[0] = 30; stems[1] = 30; stems[2] = 30
      stems[3] = 27; stems[4] = 27; stems[5] = 30
    case "EMBAUCAR":
      stem = replaceCharacterFromEnd(1, inString: stem, with: "qu")
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "u")
      stems[3] = 2; stems[4] = 2
    case "-EQUAR":
      stem3 = replaceCharacterFromEnd(3, inString: stem, with: "é")
      stems[0] = 32; stems[1] = 32; stems[2] = 32
      stems[5] = 32
    case "ENSIMESMAR":
      return [ "ensimesme/enmimmesme", "ensimesmes/entimesmes", "ensimesme", "ensimesmemos/ennosmesmemos", "ensimesmeis/envosmesmeis", "ensimesmem" ]
    case "ESMIUÇAR":
      stem = replaceCharacterFromEnd(1, inString: stem, with: "c")
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "u")
      stems[3] = 2; stems[4] = 2
    case "ESTAR", "-ESTAR":
      ends = [ "a", "as", "a", "amos", "ais", "am" ]
      stem = replaceCharacterFromEnd(1, inString: stem, with: "") + "ej"
    case "EXPLODIR", "-OUVIR":
      stems = [ 4, 4, 4, 4, 4, 4 ]
    case "FAISCAR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "qu")
      stem = replaceCharacterFromEnd(4, inString: stem2, with: "i")
      stems[0] = 2; stems[1] = 2; stems[2] = 2
      stems[5] = 2
    case "-GAR":
      stem = stem + "u"
    case "-GAUCHAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "u")
      stems[3] = 2; stems[4] = 2
    case "-GUAR", "-QUAR":
      stem2 = replaceCharacterFromEnd(1, inString: stem, with: "ú")
      stem3 = replaceCharacterFromEnd(1, inString: stem, with: "ü")
      stems = [ 24, 24, 24, 27, 27, 24 ]
    case "HAVER":
      stem = "haj"
    case "-IGUAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "í")
      stem3 = replaceCharacterFromEnd(1, inString: stem, with: "ú")
      stem4 = replaceCharacterFromEnd(1, inString: stem, with: "ü")
      stems[0] = 25; stems[1] = 25; stems[2] = 25
      stems[3] = 26; stems[4] = 26; stems[5] = 25
    case "-INGUAR", "-INQUAR", "-IQUAR":
      if variant == Variant.BPWithoutAccord { stem2 = replaceCharacterFromEnd(1, inString: stem2, with: "ü") }
    case "IR", "SOBREIR":
      ends = [ "á", "ás", "á", "amos", "ades", "ão" ]
      stem = replaceCharacterFromEnd(1, inString: stem, with: "")
    case "-MOBILIAR":
      stem2 = replaceCharacterFromEnd(3, inString: stem, with: "i")
      stems[3] = 2; stems[4] = 2
    case "-OAR", "-OER":
      stem = replaceCharacterFromEnd(1, inString: stem, with: "o")
    case "-OIAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "o")
      stems[3] = 2; stems[4] = 2
    case "-OIBIR", "PUITAR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "i")
      stems[3] = 2; stems[4] = 2
    case "-PARIR":
      stems = [ 4, 4, 4, 4, 4, 4 ]
    case "-POR":
      ends = [ "a", "as", "a", "amos", "ais", "am" ]
    case "-QUERER":
      stem = stem.substring(0, endIndex: len - 1) + "ir"
    case "REQUERER": break
    case "REUNIR":
      stem2 = replaceCharacterFromEnd(2, inString: stem, with: "u")
      stems[3] = 2; stems[4] = 2
    case "-SABER":
      stem = stem.substring(0, endIndex: len - 1) + "aib"
    case "SER", "SOBRESSER":
      ends = [ "a", "as", "a", "amos", "ais", "am" ]
      stem = stem.substring(0, endIndex: len - 1) + "ej"
    default: break
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
    
    for var i = 0; i < 6; i++ {
      switch stems[i] {
      case 0:
        bpWithAO[i] = nil
        bpWithoutAO[i] = nil
        epWithAO[i] = nil
        epWithoutAO[i] = nil
      case 1:
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 2:
        bpWithAO[i] = stem2 + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem2 + ends[i]
        epWithoutAO[i] = stem2 + ends[i]
      case 4: // use stems "stem" and "stem2" both
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
      case 13: // use "stem2" for epWithoutAO and bpWithoutAO,
        // and "stem" for epWithAO and bpWithAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem2 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem2 + ends[i]
      case 24: // use "stem" for epWithAO and bpWithAO,
        // "stem2" for epWithoutAO, and "stem3" for bpWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem3 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem2 + ends[i]
      case 25: // use "stem" and "stem2" for epWithAO and bpWithAO
        // and "stem3" for bpWithoutAO and epWithoutAO
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem3 + ends[i]
        epWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithoutAO[i] = stem3 + ends[i]
      case 26: // use "stem4" for bpWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem4 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 27: // use "stem3" for bpWithoutAO
        bpWithAO[i] = stem + ends[i]
        bpWithoutAO[i] = stem3 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 30: // use "stem" for pt and bpWithAO,
        // and "stem2" for bpWithoutAO
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem4 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem + ends[i]
      case 32:
        bpWithAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        bpWithoutAO[i] = stem + ends[i] + "/" + stem2 + ends[i]
        epWithAO[i] = stem + ends[i]
        epWithoutAO[i] = stem3 + ends[i]
      default: break // do absolutely nothing
      }
    }
    
    if variant == Variant.BPWithAccord {
      return bpWithAO;
    } else if variant == Variant.BPWithoutAccord {
      return bpWithoutAO;
    } else if variant == Variant.EPWithAccord {
      return epWithAO;
    } else {
      return epWithoutAO;
    }
  }
  
  
  /* Returns an array of optional Strings containing the imperfect subjunctive tense conjugations of the
  six Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugateImperfectSubjunctiveFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.ImperfectSubjunctive)
    stems = [Int](count: 6, repeatedValue: 1)
    
    // the default stem is derived from the 3pp form of the verb in the preterite indicative tense
    stem = getConjugatedForm(conjTable, tense: Tense.PreteriteIndicative, person: Person.ThirdPersonPlural, variant: variant)
    stem = stem.substring(0, endIndex: stem.length() - 4)
    
    var ends = [String](count: 6, repeatedValue: "")
    let regAr = [ "asse", "asses", "asse", "ássemos", "ásseis", "assem" ]
    let regEr = [ "esse", "esses", "esse", "êssemos", "êsseis", "essem" ]
    let regIr = [ "isse", "isses", "isse", "íssemos", "ísseis", "issem" ]
    
    switch verb.ending! {
    case "ar": ends = regAr
    case "er": ends = regEr
    case "ir": ends = regIr
    default: break;
    }
    
    switch type! {
    case "-AIR", "-UIR":
      ends = [ "ísse", "ísses", "ísse", "íssemos", "ísseis", "íssem" ]
    case "-CABER", "DAR", "-DAR", "-DIZER", "ESTAR", "-ESTAR", "-FAZER", "HAVER", "PODER", "-POR", "-QUERER", "-SABER", "TER", "-TER", "-TRAZER", "VIR", "-VIR":
      ends = [ "esse", "esses", "esse", "éssemos", "ésseis", "essem" ]
    case "ENSIMESMAR":
      return [ "ensimesmasse/enmimmesmasse", "ensimesmasses/entimesmasses", "ensimesmasse", "ensimesmássemos/ennosmesmássemos", "ensimesmásseis/envosmesmásseis", "ensimesmassem" ]
    case "-GUIR", "-QUIR": // regular -uir verbs
      break;
    case "IR", "SER", "SOBREIR", "SOBRESSER":
      ends = [ "osse", "osses", "osse", "ôssemos", "ôsseis", "ossem" ]
    case "VER", "-VER":
      ends = [ "isse", "isses", "isse", "íssemos", "ísseis", "issem" ]
    default: break;
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
  
    var conjugations = [String?](count: 6, repeatedValue: nil)
    for var i = 0; i < 6; i++ {
      if stems[i] != 0 { conjugations[i] = stem + ends[i] }
    }
    
    return conjugations
  }
  
  
  /* Returns an array of optional Strings containing the future subjunctive tense conjugations of the
  six Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugateFutureSubjunctiveFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.FutureSubjunctive)
    stems = [Int](count: 6, repeatedValue: 1)
    
    // the default stem is derived from the 3pp form of the verb in the preterite indicative tense
    stem = getConjugatedForm(conjTable, tense: Tense.PreteriteIndicative, person: Person.ThirdPersonPlural, variant: variant)
    stem = stem.substring(0, endIndex: stem.length() - 4)
    
    var ends = [String](count: 6, repeatedValue: "")
    let regAr = [ "ar", "ares", "ar", "armos", "ardes", "arem" ]
    let regEr = [ "er", "eres", "er", "ermos", "erdes", "erem" ]
    let regIr = [ "ir", "ires", "ir", "irmos", "irdes", "irem" ]
    
    switch verb.ending! {
    case "ar": ends = regAr
    case "er": ends = regEr
    case "ir": ends = regIr
    default: break;
    }
    
    switch type! {
    case "-AIR", "-UIR":
      ends = [ "ir", "íres", "ir", "irmos", "irdes", "írem" ]
    case "-CABER", "DAR", "-DAR", "-DIZER", "ESTAR", "-ESTAR", "-FAZER", "HAVER", "PODER", "-POR", "-QUERER", "-SABER", "TER", "-TER", "-TRAZER", "VIR", "-VIR":
      ends = [ "er", "eres", "er", "ermos", "erdes", "erem" ]
    case "ENSIMESMAR":
      return [ "ensimesmar/enmimmesmar", "ensimesmares/entimesmares", "ensimesmar", "ensimesmaremos/ennosmesmaremos", "ensimesmareis/envosmesmareis", "ensimesmarem" ]
    case "-GUIR", "-QUIR": // regular -uir verbs
      break;
    case "IR", "SER", "SOBREIR", "SOBRESSER":
      ends = [ "or", "ores", "or", "ormos", "ordes", "orem" ]
    case "VER", "-VER":
      ends = [ "ir", "ires", "ir", "irmos", "irdes", "irem" ]
    default: break;
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
    
    var conjugations = [String?](count: 6, repeatedValue: nil)
    for var i = 0; i < 6; i++ {
      if stems[i] != 0 { conjugations[i] = stem + ends[i] }
    }
    
    return conjugations
  }
  
  
  /* Returns an array of optional Strings containing the personal infinitive tense conjugations of the
  six Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugatePersonalInfinitiveFor(variant: Variant) -> [String?] {
    resetSharedProperties()
    stems = [Int](count: 6, repeatedValue: 1)
    stem = verb.infinitiveVariants[variant.rawValue]
    
    ends = [ "", "es", "", "mos", "des", "em" ]
    
    if verb.infinitive == "ensimesmar" {
      return [ "ensimesmar/enmimmesmar", "ensimesmares/entimesmares", "ensimesmar", "ensimesmarmos/ennosmesmarmos", "ensimesmardes/envosmesmardes", "ensimesmarem" ]
    }
    
    if verb.thirdPersonSingularOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0; stems[5] = 0;
    } else if verb.thirdPersonBothOnly {
      stems[0] = 0; stems[1] = 0;
      stems[3] = 0; stems[4] = 0;
    }
    
    var conjugations = [String?](count: 6, repeatedValue: nil)
    for var i = 0; i < 6; i++ {
      if stems[i] != 0 { conjugations[i] = stem + ends[i]! }
    }
    
    return conjugations
  }
  
  
  /* Returns a string containing the present participle (gerund) of the verb for the specified Variant
     (e.g. BP with AO). */
  func conjugateGerundFor(variant: Variant) -> String {
    let inf = verb.infinitiveVariants[variant.rawValue]
    stem = inf.substring(0, endIndex: inf.length() - 1)
    if inf == "pôr" { return "pondo" }
    return stem + "ndo"
  }
  
  
  // function for sure must be made private, dangerous
  
  /* Returns an array of optional Strings containing the affirmative imperative tense conjugations of the
  six Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil.  Note: the 1ps form never exists. */
  func conjugateImperativeAffirmativeFor(variant: Variant) -> [String?] {
    if verb.thirdPersonSingularOnly || verb.thirdPersonBothOnly {
      return [String?](count: 6, repeatedValue: nil)
    }
    var vós: String! = getConjugatedForm(conjTable, tense: Tense.PresentIndicative, person: Person.SecondPersonPlural, variant: variant)
    if vós != nil {
      vós = vós.substring(0, endIndex: vós.length() - 1)
    }
    let tu = getConjugatedForm(conjTable, tense: Tense.PresentIndicative, person: Person.ThirdPersonSingular, variant: variant)
    let você = getConjugatedForm(conjTable, tense: Tense.PresentSubjunctive, person: Person.ThirdPersonSingular, variant: variant)
    let nós = getConjugatedForm(conjTable, tense: Tense.PresentSubjunctive, person: Person.FirstPersonPlural, variant: variant)
    let vocês = getConjugatedForm(conjTable, tense: Tense.PresentSubjunctive, person: Person.ThirdPersonPlural, variant: variant)
    
    var conjugations: [String?] = [ nil, tu, você, nós, vós, vocês ]
    
    if verb.infinitive == "sobresser" {
      conjugations[1] = "sobressê"
      conjugations[4] = "sobressede"
    }
    
    if verb.infinitive.hasSuffix("conduzir") {
      conjugations[1] = conjugations[1]! + "/" + conjugations[1]! + "e"
    }
    
    // just added (verify)
    if verb.infinitive.hasSuffix("traduzir") {
      conjugations[1] = conjugations[1]! + "/" + conjugations[1]! + "e"
    }
    
    // just added (verify)
    if verb.infinitive.hasSuffix("trazer") {
      conjugations[1] = conjugations[1]! + "/" + conjugations[1]! + "e"
    }
    
    if (verb.infinitive == "ser") {
      conjugations[1] = "sê"
      conjugations[4] = "sede"
    }
    
     return conjugations
  }
  
  
  /* Returns an array of optional Strings containing the negative imperative tense conjugations of the
  six Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil.  Note: the 1ps form never exists. */
  func conjugateImperativeNegativeFor(variant: Variant) -> [String?] {
    if verb.thirdPersonSingularOnly || verb.thirdPersonBothOnly {
      return [String?](count: 6, repeatedValue: nil)
    }
    let tu = getConjugatedForm(conjTable, tense: Tense.PresentSubjunctive, person: Person.SecondPersonSingular, variant: variant)
    let você = getConjugatedForm(conjTable, tense: Tense.PresentSubjunctive, person: Person.ThirdPersonSingular, variant: variant)
    let nós = getConjugatedForm(conjTable, tense: Tense.PresentSubjunctive, person: Person.FirstPersonPlural, variant: variant)
    let vós = getConjugatedForm(conjTable, tense: Tense.PresentSubjunctive, person: Person.SecondPersonPlural, variant: variant)
    let vocês = getConjugatedForm(conjTable, tense: Tense.PresentSubjunctive, person: Person.ThirdPersonPlural, variant: variant)
    
    let conjugations: [String?] = [ nil, tu, você, nós, vós, vocês ]
    
    return conjugations
  }
  
  
  /* Returns a string containing the past participle of the verb for the specified Variant
  (e.g. BP with AO). */
  func conjugatePastParticipleFor(variant: Variant) -> String? {
    resetSharedProperties()
    let type = getVerbTypeFor(Tense.PastParticiple)
    stem = verb.stemVariants[variant.rawValue]
    let len = stem.length()
    
    // some verbs have multiple past participles, sometimes with different endings
    var end: String! = nil
    var end2: String! = nil
    
    let regAr = "ado"
    let regEr = "ido"
    let regIr = regEr
    
    switch verb.ending! {
    case "ar": end = regAr
    case "er": end = regEr
    case "ir": end = regIr
    default: break;
    }
    
    switch type! {
    case "-AER", "-AIR", "-OER", "-OIR", "-UER", "-UIR":
      end = "ído"
    case "-ABRIR", "-COBRIR":
      stem = stem.substring(0, endIndex: len - 1)
      end = "erto"
    case "ABSOLVER", "BENZER", "MORRER":
      stem2 = stem.substring(0, endIndex: len - 1)
      end2 = "to"
      return stem + end + "/" + stem2 + end2
    case "ACEITAR":
      if variant == Variant.BPWithAccord || variant == Variant.BPWithoutAccord {
        end2 = "o"
      } else {
        end2 = "e"
      }
      return stem + end + "/" + stem + end2
    case "ACENDER", "DISTENDER", "PRENDER", "SUSPENDER":
      stem2 = stem.substring(0, endIndex: len - 2)
      end2 = "so"
      return stem + end + "/" + stem2 + end2
    case "-ARGIR":
      stem = stem.substring(0, endIndex: len - 1)
      end = "erso"
    case "ASSENTAR": // assente used in Portugal!!!
      end2 = "e"
      return stem + end + "/" + stem + end2
    case "DISTINGUIR", "EXTINGUIR", "ROMPER":
      stem2 = stem.substring(0, endIndex: len - 2)
      end2 = "to"
      return stem + end + "/" + stem2 + end2
    case "-DIZER":
      stem = stem.substring(0, endIndex: len - 1)
      end = "to"
    case "ELEGER":
      stem2 = stem.substring(0, endIndex: len - 1)
      end2 = "ito"
      return stem + end + "/" + stem2 + end2
    case "ENCHER":
      stem2 = "ch"
      end2 = "eio"
      return stem + end + "/" + stem2 + end2
    case "ENTREGAR":
      end2 = "ue"
      return stem + end + "/" + stem + end2
    case "ENVOLVER", "ENXUGAR", "FRIGIR":
      stem2 = stem.substring(0, endIndex: len - 1)
      end2 = "to"
      return stem + end + "/" + stem2 + end2
    case "-ERGIR":
      stem2 = stem.substring(0, endIndex: len - 1)
      end2 = "so"
      return stem + end + "/" + stem2 + end2
    case "EXPRIMIR", "-IMPRIMIR":
      stem2 = stem.substring(0, endIndex: len - 2)
      end2 = "esso"
      return stem + end + "/" + stem2 + end2
    case "ANEXAR", "DESPERTAR", "DISPERSAR", "EXPRESSAR", "EXPULSAR", "FARTAR", "FINDAR", "GANHAR", "GASTAR", "ISENTAR", "JUNTAR", "LIBERTAR", "LIMPAR", "MANIFESTAR", "MURCHAR", "OCULTAR", "PAGAR", "PEGAR", "SALVAR", "SECAR", "SEGURAR", "SOLTAR", "SUJEITAR", "VAGAR":
      end2 = "o"
      return stem + end + "/" + stem + end2
    case "-FAZER":
      stem = stem.substring(0, endIndex: len - 2)
      end = "eito"
    case "-GUER", "-GUIR", "-QUER", "-QUIR": // include treme in these
      break;
    case "MATAR":
      stem2 = stem.substring(0, endIndex: len - 2)
      end2 = "orto"
      return stem + end + "/" + stem2 + end2
    case "MALQUERER":
      stem2 = stem.substring(0, endIndex: len - 2)
      end2 = "isto"
      return stem + end + "/" + stem2 + end2
    case "-SCREVER":
      stem = stem.substring(0, endIndex: len - 2)
      end = "ito"
    case "PÔR", "-POR":
      end = "osto"
    case "VER", "-VER":
      end = "isto"
    case "VIR", "-VIR":
      end = "indo"
    default:
      break;
    }
    
    return stem + end;
  }
  
  
  /* Returns an array of optional Strings containing the specified compound tense conjugations of the
  six Persons (1ps, 2ps, 3ps, 1pp, 2pp, 3pp) for the specified Variant (e.g. BP with AO).  Any
  Person's conjugation that has no proper conjugated form will be nil. */
  func conjugateCompoundTenseFor(tense: Tense, variant: Variant) -> [String?] {
    // default to present indicative tense for aux verb
    var auxiliaryVerbTense = Tense.PresentIndicative
    
    // switch otherwise
    switch tense {
    case .CompoundImperfectIndicative: auxiliaryVerbTense = Tense.ImperfectIndicative
    case .CompoundPluperfectIndicative: auxiliaryVerbTense = Tense.PluperfectIndicative
    case .CompoundFutureIndicative: auxiliaryVerbTense = Tense.FutureIndicative
    case .CompoundConditional: auxiliaryVerbTense = Tense.Conditional
    case .CompoundPresentSubjunctive: auxiliaryVerbTense = Tense.PresentSubjunctive
    case .CompoundImperfectSubjunctive: auxiliaryVerbTense = Tense.ImperfectSubjunctive
    case .CompoundFutureSubjunctive: auxiliaryVerbTense = Tense.FutureSubjunctive
    case .CompoundPersonalInfinitive: auxiliaryVerbTense = Tense.PersonalInfinitive
    default: break
    }
    
    var conjugations = [String?](count: 6, repeatedValue: nil)
    var participle = getConjugatedForm(conjTable, tense: Tense.PastParticiple, person: Person(rawValue: 0)!, variant: variant)!
    // to keep things simple, if a verb has multiple past participles, just choose the first one
    // may need to modify the order of participles to choose the one used in actual writing
    if participle.rangeOfString("/") != nil {
      let slashIndex = participle.rangeOfString("/")!.startIndex
      participle = participle.substringWithRange(participle.startIndex...slashIndex)
    }
    
    // prepend the correct conjugated forms of the auxiliary verbs to the participle
    for var i = 0; i < 6; i++ {
      conjugations[i] = getConjugatedForm(terTable, tense: auxiliaryVerbTense, person: Person(rawValue: i)!, variant: variant)! + "/"
      conjugations[i] = conjugations[i]! + getConjugatedForm(haverTable, tense: auxiliaryVerbTense, person: Person(rawValue: i)!, variant: variant)! + " " + participle
    }
    
    if verb.thirdPersonSingularOnly {
      conjugations[0] = nil; conjugations[1] = nil;
      conjugations[3] = nil; conjugations[4] = nil; conjugations[5] = nil;
    } else if verb.thirdPersonBothOnly {
      conjugations[0] = nil; conjugations[1] = nil;
      conjugations[3] = nil; conjugations[4] = nil;
    }
    
    return conjugations
  }
  
  
  /* Returns an optional String containing the compound personal infinitive conjugation for the specified Variant (e.g. BP with AO). */
  func conjugateCompoundImpersonalInfinitiveFor(variant: Variant) -> String? {
    var conjugation: String?
    var participle = getConjugatedForm(conjTable, tense: Tense.PastParticiple, person: Person(rawValue: 0)!, variant: variant)!
    // to keep things simple, if a verb has multiple past participles, just choose the first one
    // may need to modify the order of participles to choose the one used in actual writing
    if participle.rangeOfString("/") != nil {
      let slashIndex = participle.rangeOfString("/")!.startIndex
      participle = participle.substringWithRange(participle.startIndex...slashIndex)
    }
    
    // prepend the impersonal infinitive form of the auxiliary verbs to the participle
    conjugation = getConjugatedForm(terTable, tense: Tense.ImpersonalInfinitive, person: Person(rawValue: 0)!, variant: variant)! + "/"
    conjugation = conjugation! + getConjugatedForm(haverTable, tense: Tense.ImpersonalInfinitive, person: Person(rawValue: 0)!, variant: variant)! + " " + participle
    
    return conjugation
  }

  
  /* Returns an array of optional Strings consisting of the correctly conjugated forms of this verb
  in the given tense for the specified Variant (e.g. BP with AO). */
  func conjugateTense(tense: Tense, variant: Variant) -> [String?] {
    switch tense {
    case .PresentIndicative: return conjugatePresentIndicativeFor(variant)
    case .ImperfectIndicative: return conjugateImperfectIndicativeFor(variant)
    case .PreteriteIndicative: return conjugatePreteriteIndicativeFor(variant)
    case .PluperfectIndicative: return conjugatePluperfectIndicativeFor(variant)
    case .FutureIndicative: return conjugateFutureIndicativeFor(variant)
    case .Conditional: return conjugateConditionalFor(variant)
    case .PresentSubjunctive: return conjugatePresentSubjunctiveFor(variant)
    case .ImperfectSubjunctive: return conjugateImperfectSubjunctiveFor(variant)
    case .FutureSubjunctive: return conjugateFutureSubjunctiveFor(variant)
    case .PersonalInfinitive: return conjugatePersonalInfinitiveFor(variant)
    case .ImpersonalInfinitive: return [ verb.infinitiveVariants[variant.rawValue] ]
    case .ImperativeAffirmative: return conjugateImperativeAffirmativeFor(variant)
    case .ImperativeNegative: return conjugateImperativeNegativeFor(variant)
    case .Gerund: return [ conjugateGerundFor(variant) ]
    case .PastParticiple: return [ conjugatePastParticipleFor(variant) ]
    case .CompoundImpersonalInfinitive: return [ conjugateCompoundImpersonalInfinitiveFor(variant) ]
    default: // tense is compound
      return conjugateCompoundTenseFor(tense, variant: variant)
    }
  }
  
  
  /* Fills this verb's internal conjugation table with conjugated forms for each Variant for every Tense 
     whose raw value is less than or equal to the given Tense.
     
     Note: this function is useful for filling up the auxiliary verb tables. */
  func conjugateAllTensesUpTo(tense: Tense) {
    conjTable = [[[String?]]](count: Tense.count(), repeatedValue: [[String?]](count: Variant.count(), repeatedValue: [String?]()))
    
    // for each tense
    for var i = 0; i <= tense.rawValue; i++ {
      // for each variant (EP post AO, for example)
      for var j = 0; j < Variant.count(); j++ {
        // conjugate the verb for all six persons
        conjTable[i][j] = conjugateTense(Tense(rawValue: i)!, variant: Variant(rawValue: j)!)
      }
    }
  }
  
  
  /* Fills and returns this verb's internal conjugation table with conjugated forms for each Variant for every Tense. */
  func conjugateAllTenses() -> [[[String?]]] {
    // by raw value, Tense.CompoundImpersonalInfinitive is the last tense
    conjugateAllTensesUpTo(Tense.CompoundImpersonalInfinitive)
    return conjTable
  }
  
  
  /* Returns an array containing this verb's conjugations in the progressive tense for the given
     Variant. */
  private func conjugateAllProgressiveTensesFor(variant: Variant) -> [[String?]] {
    
    // we will not be using this verb's conjugation table property because we want "estar" conjugated
    var conjugations = [[String?]](count: Tense.count(), repeatedValue: [String?](count: 6, repeatedValue: nil))
    // determine the correct infinitive and gerund forms
    let infinitive = verb.infinitiveVariants[variant.rawValue]
    let gerund = conjugateGerundFor(variant)
    
    // for each tense
    for var i = 0; i < Tense.count(); i++ {
      // for each Person (1ps, 2ps, 3ps, 1pp, 2pp, 3pp)
      for var j = 0; j < Person.count(); j++ {
        
        // there are no progressive imperative forms
        if j == 0 && (i == Tense.ImperativeAffirmative.rawValue || i == Tense.ImperativeNegative.rawValue)
        {
          conjugations[i][j] = nil
        }
          
        // if tense only has a single form (no person), just get the correct "estar" form
        else if i == Tense.ImpersonalInfinitive.rawValue || i == Tense.Gerund.rawValue || i == Tense.PastParticiple.rawValue || i == Tense.CompoundImpersonalInfinitive.rawValue {
          if let estarForm: String = getConjugatedForm(estarTable, tense: Tense(rawValue: i)!, person: Person(rawValue: 0)!, variant: variant) {
            if variant == Variant.BPWithAccord || variant == Variant.BPWithoutAccord {
              conjugations[i][0] = estarForm + " " + gerund
            } else {
              conjugations[i][0] = estarForm + " a " + infinitive
            }
          }
          
          // we don't want to repeat this 6 (Person.count) times for this tense
          break
        }
        
        // for all other tenses, simply put the correct conjugated forms of "estar" in front of
        // either the gerund (BP) or the infinitive (EP) for this verb
        else {
          if let estarForm: String = getConjugatedForm(estarTable, tense: Tense(rawValue: i)!, person: Person(rawValue: j)!, variant: variant) {
            if variant == Variant.BPWithAccord || variant == Variant.BPWithoutAccord {
              conjugations[i][j] = estarForm + " " + gerund
            } else {
              conjugations[i][j] = estarForm + " a " + infinitive
            }
          }
        }
      }
      
      // for verbs only conjugated in the third person, clear out conjugations for other
      // persons except in the tenses with only one form
      if i != Tense.ImpersonalInfinitive.rawValue && i != Tense.Gerund.rawValue &&
         i != Tense.PastParticiple.rawValue && i != Tense.CompoundImpersonalInfinitive.rawValue {
        if verb.thirdPersonSingularOnly {
          conjugations[i][0] = nil; conjugations[i][1] = nil;
          conjugations[i][3] = nil; conjugations[i][4] = nil; conjugations[i][5] = nil;
        } else if verb.thirdPersonBothOnly {
          conjugations[i][0] = nil; conjugations[i][1] = nil;
          conjugations[i][3] = nil; conjugations[i][4] = nil;
        }
      }
    }
    
    // remove because this would never be used progressively:
    //conjugations[Tense.Gerund.rawValue] = [ conjugations[Tense.Gerund.rawValue][0] ]
    
    // all tenses with just one conjugation get a "dimensional size" of 1 to remove useless
    // storage of nil values
    conjugations[Tense.Gerund.rawValue] = [ nil ]
    conjugations[Tense.PastParticiple.rawValue] = [ conjugations[Tense.PastParticiple.rawValue][0] ]
    conjugations[Tense.ImpersonalInfinitive.rawValue] = [ conjugations[Tense.ImpersonalInfinitive.rawValue][0] ]
    conjugations[Tense.CompoundImpersonalInfinitive.rawValue] = [ conjugations[Tense.CompoundImpersonalInfinitive.rawValue][0] ]
    
    return conjugations
  }
  
  
  /* Returns an array containing this verb's conjugations in the progressive tense for all four
  Variants. */
  func conjugateAllProgressiveTenses() -> [[[String?]]] {
    var conjugations = [[[String?]]](count: Tense.count(), repeatedValue: [[String?]](count: Variant.count(), repeatedValue: [String?](count: Person.count(), repeatedValue: nil)))
    
    // conjugation table for each of the four Variants
    let bpWithAO = conjugateAllProgressiveTensesFor(Variant.BPWithAccord)
    let bpWithoutAO = conjugateAllProgressiveTensesFor(Variant.BPWithoutAccord)
    let epWithAO = conjugateAllProgressiveTensesFor(Variant.EPWithAccord)
    let epWithoutAO = conjugateAllProgressiveTensesFor(Variant.EPWithoutAccord)
    
    // put them all together
    var conjForVariants = [ bpWithAO, bpWithoutAO, epWithAO, epWithoutAO ]
    
    // swap the dimensions of Tense and Variant
    for var i = 0; i < Tense.count(); i++ {
      for var j = 0; j < Variant.count(); j++ {
        conjugations[i][j] = conjForVariants[j][i]
      }
    }
    
    return conjugations
  }
  
  
  /* Returns an array containing this verb's conjugations in the passive voice for the given Variant. */
  private func conjugateAllPassiveTensesFor(variant: Variant) -> [[String?]] {
    var conjugations = [[String?]](count: Tense.count(), repeatedValue: [String?](count: 6, repeatedValue: nil))
    
    // all passive voice uses the past participle
    var participle = conjugatePastParticipleFor(variant)!
    
    // if there are multiple forms of the past participle for this verb, use the first only
    if participle.rangeOfString("/") != nil {
      let slashIndex = participle.rangeOfString("/")!.startIndex
      participle = participle.substringWithRange(participle.startIndex...slashIndex)
    }
    
    // for each Tense
    for var i = 0; i < Tense.count(); i++ {
      // for each Person (1ps, 2ps, 3ps, 1pp, 2pp, 3pp)
      for var j = 0; j < Person.count(); j++ {
        
        // there are no passive commands
        if j == 0 && (i == Tense.ImperativeAffirmative.rawValue || i == Tense.ImperativeNegative.rawValue) {
          conjugations[i][j] = nil
        }
        // if tense only has a single form (no person), just get the correct "ser" form
        else if i == Tense.ImpersonalInfinitive.rawValue || i == Tense.Gerund.rawValue || i == Tense.PastParticiple.rawValue || i == Tense.CompoundImpersonalInfinitive.rawValue {
          if let serForm: String = getConjugatedForm(serTable, tense: Tense(rawValue: i)!, person: Person(rawValue: 0)!, variant: variant) {
            conjugations[i][0] = serForm + " " + participle
          }
          
          // we don't want to repeat this 6 (Person.count) times for this tense
          break
        }
        
        // for all other tenses, simply put the correct conjugated forms of "ser" in front of
        // the past participle for this verb
        else {
          if let serForm: String = getConjugatedForm(serTable, tense: Tense(rawValue: i)!, person: Person(rawValue: j)!, variant: variant) {
            conjugations[i][j] = serForm + " " + participle
            // if Person is plural, append an 's' on the end of the participle
            if j >= Person.FirstPersonPlural.rawValue {
              conjugations[i][j] = conjugations[i][j]! + "s"
            }
          }
        }
      }
      
      // for verbs only conjugated in the third person, clear out conjugations for other
      // persons except in the tenses with only one form
      if i != Tense.ImpersonalInfinitive.rawValue && i != Tense.Gerund.rawValue &&
         i != Tense.PastParticiple.rawValue && i != Tense.CompoundImpersonalInfinitive.rawValue {
        if verb.thirdPersonSingularOnly {
          conjugations[i][0] = nil; conjugations[i][1] = nil;
          conjugations[i][3] = nil; conjugations[i][4] = nil; conjugations[i][5] = nil;
        } else if verb.thirdPersonBothOnly {
          conjugations[i][0] = nil; conjugations[i][1] = nil;
          conjugations[i][3] = nil; conjugations[i][4] = nil;
        }
      }
    }
    
    // all tenses with just one conjugation get a "dimensional size" of 1 to remove useless
    // storage of nil values
    conjugations[Tense.Gerund.rawValue] = [ conjugations[Tense.Gerund.rawValue][0] ]
    conjugations[Tense.PastParticiple.rawValue] = [ conjugations[Tense.PastParticiple.rawValue][0] ]
    conjugations[Tense.ImpersonalInfinitive.rawValue] = [ conjugations[Tense.ImpersonalInfinitive.rawValue][0] ]
    conjugations[Tense.CompoundImpersonalInfinitive.rawValue] = [ conjugations[Tense.CompoundImpersonalInfinitive.rawValue][0] ]
    
    return conjugations
  }
  
  
  /* Returns an array containing this verb's conjugations in the passive voice for all four Variants. */
  func conjugateAllPassiveTenses() -> [[[String?]]] {
    var conjugations = [[[String?]]](count: Tense.count(), repeatedValue: [[String?]](count: Variant.count(), repeatedValue: [String?](count: Person.count(), repeatedValue: nil)))
    
    // conjugation table for each of the four Variants
    let bpWithAO = conjugateAllPassiveTensesFor(Variant.BPWithAccord)
    let bpWithoutAO = conjugateAllPassiveTensesFor(Variant.BPWithoutAccord)
    let epWithAO = conjugateAllPassiveTensesFor(Variant.EPWithAccord)
    let epWithoutAO = conjugateAllPassiveTensesFor(Variant.EPWithoutAccord)
    
    // put them all together
    var conjForVariants = [ bpWithAO, bpWithoutAO, epWithAO, epWithoutAO ]
    
    // swap the dimensions of Tense and Variant
    for var i = 0; i < Tense.count(); i++ {
      for var j = 0; j < Variant.count(); j++ {
        conjugations[i][j] = conjForVariants[j][i]
      }
    }
    
    return conjugations
  }
  
  /* Returns the given conjugated form with the specified object pronoun inserted into the verb.
     This is relevant to the future indicative and conditional tenses.  The index at which 
     the pronoun should be inserted is determined by insertPronoun(). */
  private func insertHelper(conjugation: String, pronoun: String, atIndex: Int) -> String {
    let len = conjugation.length()
    
    // stores everything before the two-letter infinitive ending ("ar", for example)
    let start = conjugation.substring(0, endIndex: len - atIndex - 2)
    // stores the two-letter infinitive ending
    var middle = conjugation.substring(len - atIndex - 2, endIndex: len - atIndex)
    // stores the ending that is derived from the person the form is for ("ía", for example)
    let end = conjugation.substring(len - atIndex)
    
    switch pronoun {
    // these pronouns cause changes in the "middle" section of the conjugation
    case "a", "as", "o", "os":
      switch middle {
      case "ar": middle = "á"
      case "er": middle = "ê"
      case "ir":
        let last4 = verb.infinitive.substring(verb.infinitive.length() - 4)
        for suffix in [ "guir", "güir", "quir", "qüir" ] {
          if last4 == suffix {
            middle = "i"
            break
          }
        }
        let last3 = verb.infinitive.substring(verb.infinitive.length() - 3)
        if last3 == "air" || last3 == "uir" {
          middle = "í"
          break
        }
        middle = "i"
      default: middle = "ô"
      }
    default: break
    }
    
    // put the pieces together with hypthens
    return start + middle + "-" + pronoun + "-" + end
  }
  
  
  /* Returns the given conjugated form(s) with the specified object pronoun inserted into the verb
     for the specified Tense and Person.  This is relevant to the future indicative and conditional
     tenses. */
  private func insertPronoun(pronoun: String, conjugation: String?, tense: Tense, person: Person) -> String? {
    var output = ""
    var index = 0
    var start  = ""
    var end = ""
    
    // let's not waste anyone's time, shall we?
    if conjugation == nil { return nil }
    
    start = conjugation!
    
    // if there is a space in this conjugation, we have a compound tense
    if start.rangeOfString(" ") != nil {
      let spaceIndex = start.rangeOfString(" ")!.startIndex
      
      // participle or infinitive part
      end = start.substringFromIndex(spaceIndex)
      
      // auxiliary verb part
      start = start.substringWithRange(start.startIndex...spaceIndex.predecessor())
    }
    
    // index refers to how many characters from the last the pronoun will be inserted at
    // insert only applies to future and conditional tenses
    if tense == Tense.FutureIndicative || tense == Tense.CompoundFutureIndicative {
      switch person {
      case .FirstPersonSingular, .SecondPersonSingular, .ThirdPersonPlural: index = 2
      case .ThirdPersonSingular: index = 1
      case .FirstPersonPlural: index = 4
      case .SecondPersonPlural: index = 3
      }
    } else if tense == Tense.Conditional || tense == Tense.CompoundConditional {
      switch person {
      case .FirstPersonSingular, .ThirdPersonSingular: index = 2
      case .SecondPersonSingular, .ThirdPersonPlural: index = 3
      case .SecondPersonPlural: index = 4
      case .FirstPersonPlural: index = 5
      }
    }
    
    // if there aren't multiple forms (which there will always be for the compound tenses),
    // get the completed insertion from insertHelper()
    if start.rangeOfString("/") == nil {
      return insertHelper(start, pronoun: pronoun, atIndex: index) + end
    }
    // this is the most complicated part of the code
    // this happens when there are multiple forms for this Person and Tense
    else {
      // up to four times
      for var i = 0; i < 4; i++ {
        // if there is one last conjugated form
        if start.rangeOfString("/") == nil {
          // add the last form's insertion then break and return with end attached
          output += "/" + insertHelper(start, pronoun: pronoun, atIndex: index)
          break
        }
        
        // there is another form after this one
        let slashIndex = start.rangeOfString("/")!.startIndex
        let temp = start.substringWithRange(start.startIndex...slashIndex.predecessor())
        // separate forms (don't do the first time though because we don't want to start with a '/')
        if i != 0 { output += "/" }
        // add the current form's insertion to the output
        output += insertHelper(temp, pronoun: pronoun, atIndex: index)
        // prepare to handle the next form's insertion
        start = start.substringFromIndex(slashIndex.successor())
      }
    }
    
    // append the participle, if any, to the slash-separated conjugated forms and return
    return output + end
  }
  
  
  /* Returns the given conjugated form with the specified object pronoun appended to the verb. */
  private func appendHelper(conjugation: String?, pronoun: String) -> String? {
    
    // let's not waste anyone's time, shall we? <-- seems unnecessary since checked in appendPronoun()
    if conjugation == nil { return nil }
    let len = conjugation!.length()
    
    // depending on the pronoun being appended, the verb's ending might be modified
    // if so, attach the correct pronoun and return
    switch pronoun {
    case "nos", "no-lo", "no-la", "no-los", "no-las":
      if len > 2 && conjugation!.hasSuffix("mos") {
        return conjugation!.substring(0, endIndex: len - 1) + "-" + pronoun
      }
    case "o", "a", "os", "as":
      if len >= 2 {
        let last2 = conjugation!.substring(len - 2)
        switch last2 {
        case "ar", "ás", "az": return conjugation!.substring(0, endIndex: len - 2) + "á-l" + pronoun
        case "er", "ês", "ez": return conjugation!.substring(0, endIndex: len - 2) + "ê-l" + pronoun
        case "as", "es", "és", "is", "ís", "os": return conjugation!.substring(0, endIndex: len - 1) + "-l" + pronoun
        case "ir":
          for ending in [ "guir", "güir", "quir", "qüir" ] {
            if conjugation!.hasSuffix(ending) { return conjugation!.substring(0, endIndex: len - 2) + "i-l" + pronoun }
          }
          for ending in [ "air", "uir" ] {
            if conjugation!.hasSuffix(ending) { return conjugation!.substring(0, endIndex: len - 2) + "í-l" + pronoun }
          }
          return conjugation!.substring(0, endIndex: len - 2) + "i-l" + pronoun
        case "or", "ôr", "ôs": return conjugation!.substring(0, endIndex: len - 2) + "ô-l" + pronoun
        case "uz": return conjugation!.substring(0, endIndex: len - 1) + "-l" + pronoun
        case "ão", "õe": return conjugation!.substring(0, endIndex: len - 2) + "-n" + pronoun
        case "ns": return conjugation!.substring(0, endIndex: len - 2) + "m-l" + pronoun // tens, e.g.
        default: break
        }
      }
      if conjugation!.hasSuffix("m") || conjugation!.hasSuffix("n") { return conjugation! + "-n" + pronoun }
    default: break
    }
    
    return conjugation! + "-" + pronoun
  }
  
  
  /* Returns the given conjugated form(s) with the specified object pronoun appended to the verb.
     The Variant is used to determine the appending style (with/without hyphen, for example). */
  private func appendPronoun(pronoun: String, conjugation: String?, variant: Variant) -> String? {
    var start = ""
    var end = ""
    
    // let's not waste anyone's time, shall we?
    if conjugation == nil { return nil }

    start = conjugation!
    
    // if the tense is compound
    if start.rangeOfString(" ") != nil {
      let spaceIndex = start.rangeOfString(" ")!.startIndex
      // stores the participle or infinitive
      end = start.substringFromIndex(spaceIndex)
      // stores all the auxiliary verb forms
      start = start.substringWithRange(start.startIndex...spaceIndex.predecessor())
      
      // Brazilian style is to insert the pronoun between the aux. verb and participle
      if variant == Variant.BPWithAccord || variant == Variant.BPWithoutAccord {
        return start + " " + pronoun + end
      }
    }
    
    var temp: String? = nil
    var output = ""
    
    // querer is feisty because the pronoun has different effects on each form
    if verb.infinitive == "querer" && start.hasSuffix("quere") {
      for pro in [ "o", "os", "a", "as" ] {
        if pronoun == pro {
          return appendHelper(start.substring(0, endIndex: start.length() - 6), pronoun: pronoun)! + "/" +
            appendHelper(start.substring(conjugation!.length() - 5), pronoun: pronoun)!
        }
      }
    }
    
    // if there is only one form, just get it done
    if start.rangeOfString("/") == nil { return appendHelper(start, pronoun: pronoun) }
      
    // this is the most complicated part of the code
    // this happens when there are multiple forms for this Person and Tense
    else {
      // up to four times
      for var i = 0; i < 4; i++ {
        if start.rangeOfString("/") == nil {
          // add the last form's appendix then break and return with end attached
          output += "/" + appendHelper(start, pronoun: pronoun)!
          break
        }
        // there is another form after this one
        temp = start.substringWithRange(start.startIndex...start.rangeOfString("/")!.startIndex.predecessor())
        // separate forms (don't do the first time though because we don't want to start with a '/')
        if i != 0 { output += "/" }
        output += appendHelper(temp, pronoun: pronoun)!
        // prepare to handle the next form's appending
        start = start.substringFromIndex(start.rangeOfString("/")!.startIndex.successor())
      }
    }
    
    return output + end
  }
  
  
  /* Returns the given conjugated form with the specified object pronoun prepended to the verb. */
  private func prependPronoun(conjugation: String?, pronoun: String) -> String? {
    if conjugation == nil { return nil }
    return pronoun + " " + conjugation!
  }
  
  
  /* Returns a complete conjugation table for this verb in all four Variants, with pronouns
     correctly correlated to each relevant conjugated form.  Requires a complete table of
     conjugated forms without pronouns as input. */
  private func conjugateAllTensesWithPronounsHelper(inputTable: [[[String?]]], pronouns: [String]) -> [[[String?]]] {
    var conjugations = [[[String?]]](count: conjTable.count, repeatedValue: [[String?]](count: Variant.count(), repeatedValue: [String?](count: Person.count(), repeatedValue: nil)))
    
    // for all impersonal tenses, just make the array have "dimension size" 1
    for var variant = 0; variant < Variant.count(); variant++ {
      for tense in [Tense.PastParticiple, Tense.Gerund, Tense.ImpersonalInfinitive, Tense.CompoundImpersonalInfinitive ] {
        if inputTable.count > tense.rawValue { conjugations[tense.rawValue][variant] = [String?]([nil]) }
      }
    }
    
    for var tense = 0; tense < inputTable.count; tense++ {
      for var variant = 0; variant < Variant.count(); variant++ {
        // pronouns don't go with the past participle
        if tense == Tense.PastParticiple.rawValue {
          conjugations[tense][variant][0] = inputTable[tense][variant][0]
        }
        // for the remaining impersonal tenses, just append
        else if tense == Tense.Gerund.rawValue || tense == Tense.ImpersonalInfinitive.rawValue || tense ==  Tense.CompoundImpersonalInfinitive.rawValue {
          conjugations[tense][variant][0] = appendPronoun(pronouns[Person.ThirdPersonSingular.rawValue], conjugation: inputTable[tense][variant][0], variant: Variant(rawValue: variant)!)
        }
        
        else {
          for var person = 0; person < Person.count(); person++ {
            // pronoun always appended with hyphen in affirmative commands
            if tense == Tense.ImperativeAffirmative.rawValue {
              conjugations[tense][variant][person] = appendPronoun(pronouns[person], conjugation: inputTable[tense][variant][person], variant: Variant.EPWithAccord) // append with hyphen
            }
            // pronoun always prepended in these tenses
            else if tense == Tense.CompoundPresentSubjunctive.rawValue || tense == Tense.CompoundImperfectSubjunctive.rawValue || tense == Tense.CompoundFutureSubjunctive.rawValue {
              conjugations[tense][variant][person] = prependPronoun(inputTable[tense][variant][person], pronoun: pronouns[person])
            }
            // pronouns always inserted into the verb in these tenses
            else if tense == Tense.Conditional.rawValue || tense == Tense.FutureIndicative.rawValue || tense == Tense.CompoundConditional.rawValue || tense == Tense.CompoundFutureIndicative.rawValue {
              conjugations[tense][variant][person] = insertPronoun(pronouns[person], conjugation: inputTable[tense][variant][person], tense: Tense(rawValue: tense)!, person: Person(rawValue: person)!)
            }
            // in most BP tenses and a few tenses for EP as well
            else if (variant == Variant.BPWithAccord.rawValue || variant == Variant.BPWithoutAccord.rawValue) || (tense == Tense.PresentSubjunctive.rawValue || tense == Tense.ImperfectSubjunctive.rawValue || tense == Tense.FutureSubjunctive.rawValue || tense == Tense.ImperativeNegative.rawValue) {
              // if the tense is compound
              if tense > Tense.Gerund.rawValue {
                let currentPronoun = pronouns[person]
                switch currentPronoun {
                case "o", "os", "a", "as": // really questioning this part!!!!  <--
                  // append without hyphen
                  conjugations[tense][variant][person] = appendPronoun(pronouns[person], conjugation: inputTable[tense][variant][person], variant: Variant.BPWithAccord)
                default:
                  // append with hyphen
                  conjugations[tense][variant][person] = appendPronoun(pronouns[person], conjugation: inputTable[tense][variant][person], variant: Variant.EPWithAccord)
                }
              }
              // if the tense isn't compound
              else {
                // prepend the pronouns
                conjugations[tense][variant][person] = prependPronoun(inputTable[tense][variant][person], pronoun: pronouns[person])
              }
            }
            // in most EP tenses, just append the pronouns with a hyphen
            // in the case of compound tenses, append pronoun to aux. verbs
            else {
              conjugations[tense][variant][person] = appendPronoun(pronouns[person], conjugation: inputTable[tense][variant][person], variant: Variant.EPWithAccord)
            }
          }
        }
      }
    }
    
    return conjugations
  }
  
  
  /* Returns a complete conjugation table for this verb in all four Variants, with pronouns placed in
     relation to each valid conjugated form.  Requires a complete table of conjugated forms without 
     pronouns as input.  If the second pronoun is not nil, the first must be an indirect object
     pronoun and the second must be a direct object pronoun.
    
     Note: this is not the function to use for reflexive conjugations. */
  func conjugateAllTensesWithPronouns(inputTable: [[[String?]]], pronoun1: String, pronoun2: String?) -> [[[String?]]] {
    var pronouns: [String]
    if pronoun2 == nil {
      pronouns = [String](count: 6, repeatedValue: pronoun1)
    } else {
      let contractedPronouns = contractPronouns(pronoun1, pronoun2: pronoun2)
      pronouns = [String](count: 6, repeatedValue: contractedPronouns)
    }
    
    return conjugateAllTensesWithPronounsHelper(inputTable, pronouns: pronouns)
  }
  
  
  /* Returns a complete conjugation table for this verb in all four Variants, with reflexive
     pronouns placed in relation to each valid conjugated form.  Requires a complete table of conjugated 
     forms without pronouns as input. */
  func conjugateAllReflexive(inputTable: [[[String?]]]) -> [[[String?]]] {
    let pronouns = [ "me", "te", "se", "nos", "vos", "se" ]
    return conjugateAllTensesWithPronounsHelper(inputTable, pronouns: pronouns)
  }
  
  
  /* Returns a complete conjugation table for the progressive voices of this verb, for all four Variants,
     with reflexive pronouns placed in relation to each valid conjugated form. */
  func conjugateAllProgressiveTensesReflexive() -> [[[String?]]] {
    let pronouns = [ "me", "te", "se", "nos", "vos", "se" ]
    var conjugations = conjugateAllProgressiveTenses()
    for var tense = 0; tense < Tense.count(); tense++ {
      for var person = 0; person < Person.count(); person++ {
        // for all impersonal tenses attach "se"
        if conjugations[tense][0].count == 1 {
          if conjugations[tense][0][0] != nil {
            conjugations[tense][Variant.BPWithAccord.rawValue][0] = conjugations[tense][Variant.BPWithAccord.rawValue][0]! + "-se"
            conjugations[tense][Variant.BPWithoutAccord.rawValue][0] = conjugations[tense][Variant.BPWithoutAccord.rawValue][0]! + "-se"
            conjugations[tense][Variant.EPWithAccord.rawValue][0] = appendHelper(conjugations[tense][Variant.EPWithAccord.rawValue][0], pronoun: "se")
            conjugations[tense][Variant.EPWithoutAccord.rawValue][0] = appendHelper(conjugations[tense][Variant.EPWithoutAccord.rawValue][0], pronoun: "se")
          }
          // since we know this is an impersonal tense, we should skip the next five persons
          break
        }
        // in all subjunctive tenses, prepend the pronoun to the conjugation
        else if tense == Tense.PresentSubjunctive.rawValue || tense == Tense.ImperfectSubjunctive.rawValue || tense == Tense.FutureSubjunctive.rawValue || tense == Tense.ImperativeNegative.rawValue || tense == Tense.CompoundPresentSubjunctive.rawValue || tense == Tense.CompoundImperfectSubjunctive.rawValue || tense == Tense.CompoundFutureSubjunctive.rawValue {
          for var variant = 0; variant < Variant.count(); variant++ {
            conjugations[tense][variant][person] = prependPronoun(conjugations[tense][variant][person], pronoun: pronouns[person])
          }
        }
        // for all other tenses, append pronoun by hand (BP) or use appendHelper() (EP)
        else {
          if conjugations[tense][Variant.BPWithAccord.rawValue][person] != nil {
            conjugations[tense][Variant.BPWithAccord.rawValue][person] = conjugations[tense][Variant.BPWithAccord.rawValue][person]! + "-" + pronouns[person]
          }
          if conjugations[tense][Variant.BPWithoutAccord.rawValue][person] != nil {
            conjugations[tense][Variant.BPWithoutAccord.rawValue][person] = conjugations[tense][Variant.BPWithoutAccord.rawValue][person]! + "-" + pronouns[person]
          }
          conjugations[tense][Variant.EPWithAccord.rawValue][person] = appendHelper(conjugations[tense][Variant.EPWithAccord.rawValue][person], pronoun: pronouns[person])
          conjugations[tense][Variant.EPWithoutAccord.rawValue][person] = appendHelper(conjugations[tense][Variant.EPWithoutAccord.rawValue][person], pronoun: pronouns[person])
        }
      }
    }
    
    return conjugations
  }
  
  
  /* Returns a complete conjugation table for the progressive voices of this verb, for all four Variants,
  with pronouns placed in relation to each valid conjugated form. */
  func conjugateAllProgressiveTensesWithPronouns(pronoun1: String, pronoun2: String?) -> [[[String?]]] {
    let pronoun = contractPronouns(pronoun1, pronoun2: pronoun2)
    var conjugations = conjugateAllProgressiveTenses()
    for var tense = 0; tense < Tense.count(); tense++ {
      for var person = 0; person < Person.count(); person++ {
        // for all impersonal tenses attach "pronoun"
        if conjugations[tense][0].count == 1 {
          if conjugations[tense][0][0] != nil {
            conjugations[tense][Variant.BPWithAccord.rawValue][0] = conjugations[tense][Variant.BPWithAccord.rawValue][0]! + "-" + pronoun
            conjugations[tense][Variant.BPWithoutAccord.rawValue][0] = conjugations[tense][Variant.BPWithoutAccord.rawValue][0]! + "-" + pronoun
            conjugations[tense][Variant.EPWithAccord.rawValue][0] = appendHelper(conjugations[tense][Variant.EPWithAccord.rawValue][0]!, pronoun: pronoun)
            conjugations[tense][Variant.EPWithoutAccord.rawValue][0] = appendHelper(conjugations[tense][Variant.EPWithoutAccord.rawValue][0]!, pronoun: pronoun)
          }
          // since we know this is an impersonal tense, we should skip the next five persons
          break
        }
        // in all subjunctive tenses, prepend the pronoun to the conjugation
        else if tense == Tense.PresentSubjunctive.rawValue || tense == Tense.ImperfectSubjunctive.rawValue || tense == Tense.FutureSubjunctive.rawValue || tense == Tense.ImperativeNegative.rawValue || tense == Tense.CompoundPresentSubjunctive.rawValue || tense == Tense.CompoundImperfectSubjunctive.rawValue || tense == Tense.CompoundFutureSubjunctive.rawValue {
          for var variant = 0; variant < Variant.count(); variant++ {
            conjugations[tense][variant][person] = prependPronoun(conjugations[tense][variant][person], pronoun: pronoun)
          }
        }
        // for all other tenses, append pronoun by hand (BP) or use appendHelper() (EP)
        else {
          if conjugations[tense][Variant.BPWithAccord.rawValue][person] != nil {
            conjugations[tense][Variant.BPWithAccord.rawValue][person] = conjugations[tense][Variant.BPWithAccord.rawValue][person]! + "-" + pronoun
          }
          if conjugations[tense][Variant.BPWithoutAccord.rawValue][person] != nil {
            conjugations[tense][Variant.BPWithoutAccord.rawValue][person] = conjugations[tense][Variant.BPWithoutAccord.rawValue][person]! + "-" + pronoun
          }
          conjugations[tense][Variant.EPWithAccord.rawValue][person] = appendHelper(conjugations[tense][Variant.EPWithAccord.rawValue][person], pronoun: pronoun)
          conjugations[tense][Variant.EPWithoutAccord.rawValue][person] = appendHelper(conjugations[tense][Variant.EPWithoutAccord.rawValue][person], pronoun: pronoun)
        }
      }
    }
    
    return conjugations
  }
  
  
  /* Returns a complete conjugation table for the progressive voices of this verb, for all four Variants,
  with an indirect object pronoun placed in relation to each valid conjugated form. */
  func conjugateAllPassiveTensesWithPronouns(pronoun: String) -> [[[String?]]] {
    let validPronouns = [ "me", "te", "lhe", "nos", "vos", "lhes" ]
    var conjugations: [[[String?]]]
    
    // if the pronoun is valid, place the pronoun where it's supposed to go for each Tense and Variant
    // otherwise just return an 3-D array will one element: nil
    for pro in validPronouns {
      if pro == pronoun {
        conjugations = conjugateAllPassiveTenses()
        for var tense = 0; tense < Tense.count(); tense++ {
          for var person = 0; person < Person.count(); person++ {
            // for all impersonal tenses attach "pronoun"
            if conjugations[tense][0].count == 1 {
              for var variant = 0; variant < Variant.count(); variant++ {
                conjugations[tense][variant][0] = appendPronoun(pronoun, conjugation: conjugations[tense][variant][0], variant: Variant(rawValue: variant)!)
              }
              // since we know this is an impersonal tense, we should skip the next five persons
              break
            }
            // in all subjunctive tenses, prepend the pronoun to the conjugation
            if tense == Tense.PresentSubjunctive.rawValue || tense == Tense.ImperfectSubjunctive.rawValue || tense == Tense.FutureSubjunctive.rawValue || tense == Tense.CompoundPresentSubjunctive.rawValue || tense == Tense.CompoundImperfectSubjunctive.rawValue || tense == Tense.CompoundFutureSubjunctive.rawValue {
              for var variant = 0; variant < Variant.count(); variant++ {
                conjugations[tense][variant][person] = prependPronoun(conjugations[tense][variant][person], pronoun: pronoun)
              }
            }
            // for all compound tenses, append the pronoun to the aux. verb conjugation
            else if tense > Tense.Gerund.rawValue {
              for var variant = 0; variant < Variant.count(); variant++ {
                conjugations[tense][variant][person] = appendPronoun(pronoun, conjugation: conjugations[tense][variant][person], variant: Variant(rawValue: variant)!)
              }
            }
            // for all other tenses, prepend pronoun (BP) or use appendPronoun() (EP)
            else {
              conjugations[tense][Variant.BPWithAccord.rawValue][person] = prependPronoun(conjugations[tense][Variant.BPWithAccord.rawValue][person], pronoun: pronoun)
              conjugations[tense][Variant.BPWithoutAccord.rawValue][person] = prependPronoun(conjugations[tense][Variant.BPWithoutAccord.rawValue][person], pronoun: pronoun)
              conjugations[tense][Variant.EPWithAccord.rawValue][person] = appendPronoun(pronoun, conjugation: conjugations[tense][Variant.EPWithAccord.rawValue][person], variant: .EPWithAccord)
              conjugations[tense][Variant.EPWithoutAccord.rawValue][person] = appendPronoun(pronoun, conjugation: conjugations[tense][Variant.EPWithoutAccord.rawValue][person], variant: .EPWithoutAccord)
            }
          }
        }
        return conjugations
      }
    }
    
    return [[[String?]]](count: 1, repeatedValue: [[String?]](count: 1, repeatedValue: [String?](count: 1, repeatedValue: nil)))
  }
  
  
  /* Given either one or two pronouns, returns a contraction.  If the second pronoun is not nil, the first 
     must be an indirect object pronoun and the second must be a direct object pronoun. */
  private func contractPronouns(pronoun1: String, pronoun2: String?) -> String {
    if pronoun2 == nil { return pronoun1 }
    
    switch pronoun2! {
    case "o":
      switch pronoun1 {
      case "me": return "mo"
      case "te": return "to"
      case "lhe", "lhes": return "lho"
      case "nos": return "no-lo"
      case "vos": return "vo-lo"
      default: return "ERROR" // ?
      }
    case "a":
      switch pronoun1 {
      case "me": return "ma"
      case "te": return "ta"
      case "lhe", "lhes": return "lha"
      case "nos": return "no-la"
      case "vos": return "vo-la"
      default: return "ERROR" // ?
      }
    case "os":
      switch pronoun1 {
      case "me": return "mos"
      case "te": return "tos"
      case "lhe", "lhes": return "lhos"
      case "nos": return "no-los"
      case "vos": return "vo-los"
      default: return "ERROR" // ?
      }
    case "as":
      switch pronoun1 {
      case "me": return "mas"
      case "te": return "tas"
      case "lhe", "lhes": return "lhas"
      case "nos": return "no-las"
      case "vos": return "vo-las"
      default: return "ERROR" // ?
      }
    default: return pronoun1 + "-" + pronoun2!
    }
  }
  
  
  func conjugateAllForVariant(inputTable: [[[String?]]], variant: Variant) -> [[String?]] {
    
    var conjugations: [[String?]] = [[String?]](count: inputTable.count,
      repeatedValue: [String?](count: Person.count(), repeatedValue: nil))
    for var tense = 0; tense < conjugations.count; tense++ {
      conjugations[tense] = inputTable[tense][variant.rawValue]
    }
    
    return conjugations
  }
  
  
  /* Returns the conjugated form of this verb for the given tense, person, and variant.  An input table
     filled with conjugations must be passed as a parameter. */
  private func getConjugatedForm(inputTable: [[[String?]]], tense: Tense, person: Person, variant: Variant) -> String? {
    return inputTable[tense.rawValue][variant.rawValue][person.rawValue]
  }
  
  
  /* NOTES */
  static func getConjugationTableWithOptions(options: VerbOptions?) -> [[String?]]? {
    if options == nil { return nil }
    
    prepareAuxTables()
    
    let conjugator = Conjugator(verb: options!.verb)!
    var baseConj: [[[String?]]] = conjugator.conjugateAllTenses()
    
    if options!.pronoun1 == nil {
      // what the heck is this????
      if options!.mood == "regular" {
      } else if options!.mood == "passive" {
        return conjugator.conjugateAllPassiveTensesFor(options!.variant)
      } else {
        return conjugator.conjugateAllProgressiveTensesFor(options!.variant)
      }
    }
    else if options!.pronoun1 == "se" {
      if options!.mood == "progressive" {
        baseConj = conjugator.conjugateAllProgressiveTensesReflexive()
      }
      // assume regular
      baseConj = conjugator.conjugateAllReflexive(baseConj)
    }
    else {
      // assume there is at least one pronoun
      if options!.mood == "regular" {
        baseConj = conjugator.conjugateAllTensesWithPronouns(baseConj, pronoun1: options!.pronoun1!, pronoun2: options!.pronoun2)
      } else if options!.mood == "passive" {
        // this assumes only pronoun1 is defined
        baseConj = conjugator.conjugateAllPassiveTensesWithPronouns(options!.pronoun1!)
      } else {
        baseConj = conjugator.conjugateAllProgressiveTensesWithPronouns(options!.pronoun1!, pronoun2: options!.pronoun2)
      }
    }
    return conjugator.conjugateAllForVariant(baseConj, variant: options!.variant)
  }
} // end Conjugator class


/* This enum type stores the six persons for which a verb may be conjugated: FirstPersonSingular (1ps),
   SecondPersonSingular (2ps), ThirdPersonSingular (3ps), FirstPersonPlural (1pp),
   SecondPersonPlural (2pp), ThirdPersonPlural (3pp). */
enum Person: Int {
  case FirstPersonSingular = 0, SecondPersonSingular, ThirdPersonSingular, FirstPersonPlural, SecondPersonPlural, ThirdPersonPlural
  
  /* Returns the number of constants in this enum. */
  static func count() -> Int {
    return Person.ThirdPersonPlural.rawValue + 1
  }
}


/* This enum type stores the four pairwise combinations of conjugation rules: Brazilian vs. European
   Portuguese and Pre- vs. Post-"Acordo Ortográfico". */
enum Variant: Int {
  case BPWithAccord = 0, BPWithoutAccord, EPWithAccord, EPWithoutAccord
  
  /* Returns the number of constants in this enum. */
  static func count() -> Int {
    return Variant.EPWithoutAccord.rawValue + 1
  }
}


/* This enum type stores the 25 basic tenses for which a verb may be conjugated, including the gerund,
   past participle, and impersonal infinitive. */
enum Tense: Int {
  case PresentIndicative = 0, ImperfectIndicative, PreteriteIndicative, PluperfectIndicative, FutureIndicative, Conditional, PresentSubjunctive, ImperfectSubjunctive, FutureSubjunctive, PersonalInfinitive, ImpersonalInfinitive, ImperativeAffirmative, ImperativeNegative, Gerund, PastParticiple, CompoundPresentIndicative, CompoundImperfectIndicative, CompoundPluperfectIndicative, CompoundFutureIndicative, CompoundConditional, CompoundPresentSubjunctive, CompoundImperfectSubjunctive, CompoundFutureSubjunctive, CompoundPersonalInfinitive, CompoundImpersonalInfinitive
  
  /* Returns the number of constants in this enum. */
  static func count() -> Int {
    return Tense.CompoundImpersonalInfinitive.rawValue + 1
  }
}

/* Add some useful capabilities to the String class, given that this class involves a large amount of
   String manipulation. */
extension String {
  /* Returns the Character stored at the specified index of this String.*/
  func charAt(index: Int) -> Character {
    let charInd = self.startIndex.advancedBy(index)
    return self[charInd]
  }
  
  /* Wrapper function for count() (formerly countElements() ). */
  func length() -> Int {
    return self.characters.count
  }
  
  /* Port of Java's substring method taking only the start index. */
  func substring(startIndex: Int) -> String {
    let start = self.startIndex.advancedBy(startIndex)
    return self.substringFromIndex(start)
  }
  
  /* Port of Java's substring method taking both the start and end indices.
     Note: the substring's last Character is the one before the end index. */
  func substring(startIndex: Int, endIndex: Int) -> String {
    let length = endIndex - startIndex
    let start = self.startIndex.advancedBy(startIndex)
    let end = self.startIndex.advancedBy(startIndex + length)
    return self.substringWithRange(Range<String.Index>(start: start, end: end))
  }
}

struct VerbOptions {
  var verb: Verb?
  
  var mood: String? = nil
  
  var pronoun1: String?
  
  var pronoun2: String?
  
  var variant: Variant
  
  /* If passed a valid verb, mood, and optionally pronoun(s), initializes a new VerbOptions object.  
     Otherwise, returns nil. */
  init?(infinitive: String, variant: Variant, mood: String, pronoun1: String?, pronoun2:String?) {
    self.verb = Verb(infinitive: infinitive)
    if verb == nil {
      return nil
    }
    
    self.variant = variant
    
    for m in [ "regular", "passive", "progressive" ] {
      if m == mood {
        self.mood = mood
      }
    }
    
    if self.mood == nil { return nil }
    
    if pronoun2 == nil {
      if pronoun1 == nil || isValidIOP(pronoun1!) || isValidDOP(pronoun1!) || pronoun1 == "se" {
        self.pronoun1 = pronoun1
        self.pronoun2 = pronoun2
      } else {
        return nil
      }
    }
    // there is a second pronoun
    else {
      if pronoun1 == nil {
        return nil
      } else if isValidIOP(pronoun1!) && isValidDOP(pronoun2!) {
        self.pronoun1 = pronoun1
        self.pronoun2 = pronoun2
      } else {
        return nil
      }
    }
  }
  
  private func isValidDOP(pro: String) -> Bool {
    for p in [ "me", "te", "o", "a", "nos", "vos", "os", "as" ] {
      if p == pro { return true }
    }
    return false
  }
  
  private func isValidIOP(pro: String) -> Bool {
    for p in [ "me", "te", "lhe", "nos", "vos", "lhes" ] {
      if p == pro { return true }
    }
    return false
  }
}