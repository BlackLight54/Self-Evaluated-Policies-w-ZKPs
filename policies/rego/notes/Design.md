# Cél
A célom egy olyan REGO policy(k) elkészítése, amelly(ek)el OPA segítségével, VP alapján ellenőrizni tudjuk, hogy egy adott személy jogosult-e gázártámogatásra, és ha igen, akkor milyen összegben. A policy publikálva van az ellenőrző szerv által, ideálisan valamilyen Trusted Registry-ben(ez lehet akár DLT alapú), a felhasználó így juthat hozzá. A kiértékelés megtörténhet mind az ellenőrző szerv, mind felhasználó oldalán, és ugyan arra az eredményre kell jusson, így biztosítva a bizalmat.
Ebben a példában a kiértékelés havonta történik, az azt megelőző 12 hónap álagával hasonlítjuk össze.

# Mi alapján adhatunk támogatást?
- Gazdaságilag kiszolgáltatott csoporthoz való tartozás
	- Változott munkaképességűek
	- Gyerekes családok/nagycsaládok
	- Diákok/Egyetemisták
- *Megtakarítás*: Korábbi historikus fogyasztésunkhoz képest kevesebbet fogyaztunk
	
- ?Környezetkímélő berendezés(Inverteres klíma, elektromos bojler, stb.) vásárlása - nyugta VC bemutatása

# [[Components]]

## Inputs/Query

### Milyen VC-ket kezel a policy?
Az OPA a VC-ket egy Verifiable Presentation formájában kapja meg, amely tartalmazhatja a következő tíusú VC-ket:
- Korlátozott munkaképesség igazolás
	- Minősítési kategória: B1, B2, C1, C2, D, E
	- Százalék
<!---
- Környezetkímélő berendezés hiteles nyugtája
	- Termék neve
	- Fizetés dátuma
--->
- Korábbi fogyasztások igazolása
	- Hónap, amelyre vonatkozik
	- Fogyasztás mértéke (m^3)

Példa: ![[skeletonVP.json]]
### Milyen egyéb, nem VC-be ágyazott, felhasználótól származó adatot kezel a policy?
- Jelenlegi, még nem igazolt fogyasztás(m^3)
- Aktuális gázár (Ft/m^3)([[Design#Milyen egyéb, ***nem*** felhasználótól származó adatokat kezel a policy?|miért itt adjuk meg?]])
- Várt támogatás mennyisége(Ft)
Példa: 
>[!info]- Gázár és fogyasztás viszonya
> A földgáz esetén  nagyon változó mind szolgáltató, mind a mérőhely szerint a köbméterre vetített érték és ár
> Emiatt nem fogyasztott köbméterrel számolunk, hanem a az univerzálisnak tekinthető hőértékkel, kWh alapon
### Milyen egyéb, ***nem*** felhasználótól származó adatokat kezel a policy?
- Jelenleg nincs ilyen input
> [!danger] Nem felhasználótól származó adatok veszélye
> A policy ilyen adatot csak úgy kezelhet, ha azt képesek vagyunk biztonságosan, valamilyen publikus Trusted Registry-ről beszerezni, úgy hogy a kiértékelő felhasználó, és az ellenőrző szerv is hozzáfér.
> Erre még nem találtam vagy készítettem az OPA-hoz automatizált megoldást, ezért a közös adatokat is a User viszi be.

## Outputs/Decision
- Támogatás nélküli fizetendő összeg
- Támogatás figyelembevételével fizetendő összeg
- Támogatás mennyisége
- Bool-változó, hogy megegyezik-e a bemenetként kapott várt értékkel a tám
> [!info]- Miért van szükség ilyen Bool-változóra?
> Több keretrendszer, mint például az általam használt *walt.id*  az OPA-tól nem egy komplex policy kiértékelést vár, hanem pusztán egy igen-nem választ, hogy a kiértékelés során elfogadhatónak találtuk-e az adott query-t 

## Policy


