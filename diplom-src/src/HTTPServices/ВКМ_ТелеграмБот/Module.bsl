
Функция PingGETPing(Запрос) 
	
	Попытка
		//ОТвет = Новый HTTPСервисОтвет(200);
		//Ответ.УстановитьТелоИзСтроки("OK"); 
		Ответ = ВКМ_ОбщегоНазначенияHTTP.ПростойОтвет(); 
		//Ответ = ВКМ_ОбщегоНазначенияHTTP.СообщениеВТелеграм(); 
		//Ответ = ВКМ_Телеграм.ОбработатьЗапрос(Запрос);

		// 
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Ответ = ВКМ_ОбщегоНазначенияHTTP.ОтветОбОшибке(ИнформацияОбОшибке);
	КонецПопытки;
	
	Возврат Ответ;
	
КонецФункции

Функция SendPOSTSend(Запрос)   Экспорт    // (Запрос)
	
	УстановитьПривилегированныйРежим(Истина); 
		//Ответ = ВКМ_ОбщегоНазначенияHTTP.ПростойОтвет(); 
	Попытка 
		
		Ответ = ВКМ_ОбщегоНазначенияHTTP.СообщениеВТелеграм() ;
		//Ответ = ВКМ_Телеграм.ОтправитьСообщение(Запрос);          //(Запрос) 
	Исключение
		ИнформацияОбОшибке = ИнформацияОбОшибке();
		Ответ = ВКМ_ОбщегоНазначенияHTTP.ОтветОбОшибке(ИнформацияОбОшибке);
	КонецПопытки;
	
	Возврат Ответ;
	
   КонецФункции
