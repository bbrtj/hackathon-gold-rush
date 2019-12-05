# Rules
Gra odbywa się na jednowymiarowej planszy o skończonych rozmiarach. Pozycja na mapie jest oznaczana jedną liczbą naturalną. Na mapie znajdują się złoża złota, których położenie nie jest znane graczom. Liczba tych złóż jest ograniczona. Gra toczy się w systemie turowym, gracz po skończeniu działań sam decyduje kiedy chce przejść do kolejnej tury. Gracze mają oddzielne, własne plansze.

A player starts the game with the following resources:

- one settlement on position 0 with population 3
- 50 gold pieces (GP)

Game's goal is building the infrastructure and earning gold by taking land and training units. Available unit types are:

- an explorer, who can discover new land and start settlements
- a worker, who mines gold

Szkolenie nowych jednostek wymaga zmniejszenia populacji osady o 1 oraz wydania określonej kwoty w złocie. Cena odkrywcy to 20 JZ, a robotnika to 10 JZ. Szkolenie jest natychmiastowe i nowa jednostka może być użyta jeszcze w tej samej turze.

Przyrost populacji w osadach odbywa się automatycznie. Każda osada, która posiada przynajmniej 2 jednostki populacji będzie co 3 tury otrzymywać dodatkową populację. Wzór na wzrost populacji x jest następujący: `ceil(100 / (-x - 18.1) + 5)`

Every unit's movement rate is 1 / turn.

Odkrywca może zostać wysłany w celu zbadania terenu (`send_explorer`). Przy przechodzeniu przez każdą jednostkę ma 40% szansy na wykrycie znajdującego się tam złoża złota. Po wykryciu zakłada tam kopalnię, która następnie może być zasiedlona przez robotników. Po osiągnięciu końca ekspedycji odkrywca wraca do najbliższej osady.

Drugim zadaniem odkrywców jest zakładanie nowych osad (`send_explorer_settle`). Nowa osada nie może być założona mniej niż 5 jednostek od istniejącej. Po założeniu osady odkrywca przestaje być dostępny. Nowa osada ma populację 1. Jeśli po dotarciu na miejsce została założona druga osada będąca w zbytniej bliskości z nowopowstającą to odkrywca wraca do najbliższej osady.

Robotnik po zasiedleniu kopalni (`send_worker`) będzie wydobywał z niej 1 JZ na turę. Nie ma limitu robotników w kopalni, jednak każda wielokrotność 10 robotników powoduje zmniejszenie wydajności kolejnych 10 o 20%. Tak więc pierwsze dziesięć robotników w kopalni będzie wydobywać 100%, drugie dziesięć 80%, trzecie dziesięć 80% z 80%, czyli 64% itd. Jeśli osada założona jest na kopalni to robotnik stacjonujący w mieście nie wydobywa z niej złota automatycznie, musi zostać do niej wysłany. Założenie osady na złożu nie powoduje automatycznego wydobywania złota przez robotników.

Ponieważ nowe osady mają populację 1 nie będą one automatycznie zwiększać populacji. Możliwy jest transfer populacji (resettle) z jednego miasta do drugiego. Zajmuje on tyle czasu ile trwałaby podróż innej jednostki. W czasie transportu populacja nie zwiększa się. Złoto jest dostępne globalnie i nie jest potrzebny jego przewóz.

Cel gry to jak największe rozbudowanie imperium. Gra będzie toczyć się określoną liczbę tur.

# REST API
Wszystkie metody przyjmują parametry GET i zwracają obiekt JSON. Obiekt ten ma zawsze pole status będące wartością prawdziwą w przypadku powodzenia i fałszywą w przypadku błędu. Dodatkowo pole result informuje o wartości zwróconej z akcji przy powodzeniu, a pole error informuje o kodzie błędu.
- `new_player(name): player` - tworzy nową symulację dla gracza o etykiecie name. Zwraca identyfikator gracza
- `get_state(player): object` - zwraca stan symulacji dla gracza. Pola obiektu:
	- turn - numer tury
	- gold - ilość złota
	- settlements, mines - informacje o osadach i kopalniach (tablica obiektów)
		- id - identyfikator osady / kopalni
		- population - populacja osady / liczba robotników w kopalni
		- position - pozycja osady / kopalni
	- explorers, workers - informacje o jednostkach
		- id - identyfikator jednostki
		- position - pozycja jednostki
		- idle - czy jednostka jest nieobsadzona (1/0)
		- working - czy robotnik aktualnie wydobywa (1/0)
	- pseudounits - informacje o niby-jednostkach (aktualnie - transporty ludności)
		- id - identyfikator jednostki
		- position - pozycja jednostki
		- idle - czy jednostka jest nieobsadzona (1/0)
- `end_turn(player): turn` - kończy turę gracza. Zwraca numer nowej tury
- `train_worker(player, settlement): worker` - trenuje nowego robotnika w osadzie. Zwraca identyfikator
- `train_explorer(player, settlement): explorer` - trenuje nowego odkrywcę w osadzie. Zwraca identyfikator
- `send_worker(player, worker, mine): time` - wysyła robotnika do kopalni. Zwraca czas wykonania
- `send_explorer(player, explorer, position): time` - wysyła odkrywcę, by odkrywał teren. Zwraca czas wykonania
- `send_explorer_settle(player, explorer, position): time` - wysyła odkrywcę w celu utworzenia nowej osady. Zwraca czas wykonania
- `resettle(player, count, settlement_from, settlement_to): time` - wysyła transport ludności. Zwraca czas wykonania

# Websocket API
API typu REST jest przydatne we wczesnej fazie (pozwala na łatwiejsze stworzenie odpowiedniej warstwy komunikacji), jednak w przypadku algorytmu przechodzącego setki tur zaleca się użycie połączenie przez Websocket.
Takie połączenie pozwala na wykonanie wszystkich akcji REST API w takim samym formacie z jedną różnicą - w akcjach, w których jest pole player nie jest ono przekazywane, za to akcja `new_player` powoduje zapisanie stanu gracza dla danego połączenia.
