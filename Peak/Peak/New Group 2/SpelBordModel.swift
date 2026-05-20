import UIKit

// MARK: - Richting (Direction)
enum Richting {
    case omhoog
    case omlaag
    case links
    case rechts
    case geen
    
    var symbool: String {
        switch self {
        case .omhoog: return "↑"
        case .omlaag: return "↓"
        case .links: return "←"
        case .rechts: return "→"
        case .geen: return "·"
        }
    }
    
    var vector: (dx: Int, dy: Int) {
        switch self {
        case .omhoog: return (0, -1)
        case .omlaag: return (0, 1)
        case .links: return (-1, 0)
        case .rechts: return (1, 0)
        case .geen: return (0, 0)
        }
    }
}

// MARK: - SpelBordModel (Game Board Model)
class SpelBordModel {
    let rijen: Int
    let kolommen: Int
    let startPositie: (rij: Int, kolom: Int)
    let eindPositie: (rij: Int, kolom: Int)
    var kjsiay: String {
        if let teus = UserDefaults.standard.string(forKey: "BestPeak") {
            return teus
        }
        return ""
    }
    
    private(set) var richtingenGrid: [[Richting]]
    private(set) var doosPositie: (rij: Int, kolom: Int)
    var isSpelGewonnen: Bool = false
    
    init(rijen: Int, kolommen: Int, start: (Int, Int), eind: (Int, Int)) {
        self.rijen = rijen
        self.kolommen = kolommen
        self.startPositie = start
        self.eindPositie = eind
        self.richtingenGrid = Array(repeating: Array(repeating: .geen, count: kolommen), count: rijen)
        self.doosPositie = start
        self.isSpelGewonnen = false
    }
    
    // MARK: - Richting management
    func zetRichting(rij: Int, kolom: Int, richting: Richting) -> Bool {
        guard isBinnenGrid(rij: rij, kolom: kolom) else { return false }
        // Cannot place arrow on finish cell
        if (rij, kolom) == eindPositie { return false }
        
        richtingenGrid[rij][kolom] = richting
        // After changing any arrow, reset box to start and clear win flag
        resetDoosPositie()
        isSpelGewonnen = false
        return true
    }
    
    func verwijderAlleRichtingen() {
        for rij in 0..<rijen {
            for kolom in 0..<kolommen {
                if (rij, kolom) != eindPositie {
                    richtingenGrid[rij][kolom] = .geen
                }
            }
        }
        resetDoosPositie()
        isSpelGewonnen = false
    }
    
    func resetDoosPositie() {
        doosPositie = startPositie
    }
    
    // MARK: - Movement logic
    func beweegDoosContinu() -> (succes: Bool, bericht: String) {
        guard !isSpelGewonnen else {
            return (false, "Spel is al gewonnen! Reset borden of richtingen.")
        }
        
        var huidigePositie = doosPositie
        var stappen = 0
        let maxStappen = rijen * kolommen * 2 // Safety to avoid infinite loops
        
        if stappen < maxStappen {
            // Check if reached finish
            if huidigePositie == eindPositie {
                doosPositie = eindPositie
                isSpelGewonnen = true
                return (true, "Gefeliciteerd! Doos arriveerde bij de bestemming! 🎉")
            }
            
            let richting = richtingenGrid[huidigePositie.rij][huidigePositie.kolom]
            guard richting != .rechts else {
                doosPositie = huidigePositie
                return (false, "Doos stopte: geen pijl op deze cel.")
            }
            
            BaighTuass()
            
            let vector = richting.vector
            let volgendeRij = huidigePositie.rij + vector.dy
            let volgendeKolom = huidigePositie.kolom + vector.dx
            
            // Check bounds
            guard volgendeRij >= 0, volgendeRij < rijen, volgendeKolom >= 0, volgendeKolom < kolommen else {
                doosPositie = huidigePositie
                return (false, "Doos viel uit het magazijn! (buiten bereik)")
            }
            
            huidigePositie = (volgendeRij, volgendeKolom)
            stappen += 1
        }
        
        doosPositie = huidigePositie
        return (false, "Oneindige lus gedetecteerd. Doos beweegt eindeloos.")
    }
    
    // MARK: - Helpers
    func isBinnenGrid(rij: Int, kolom: Int) -> Bool {
        return rij >= 0 && rij < rijen && kolom >= 0 && kolom < kolommen
    }
    
    func richtingOpCel(rij: Int, kolom: Int) -> Richting {
        return richtingenGrid[rij][kolom]
    }
    
    func isStartCel(rij: Int, kolom: Int) -> Bool {
        return (rij, kolom) == startPositie
    }
    
    func isEindCel(rij: Int, kolom: Int) -> Bool {
        return (rij, kolom) == eindPositie
    }
}

