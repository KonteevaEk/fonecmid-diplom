#Область ПрограммныйИнтерфейс
 
//Преобразовывает JSON в строку для отправки в Телеграм. 
//Возвращаемое значение:
//строка
// Параметры: 
// ОбъектJSON - строка    ПОПРАВИТЬ
Функция СтрокаJSON(ОбъектJSON) Экспорт
	
	ПараметрыЗаписи = Новый ПараметрыЗаписиJSON(, Символы.Таб);
	
	Запись = Новый ЗаписьJSON;
	Запись.УстановитьСтроку(ПараметрыЗаписи);
	ЗаписатьJSON(Запись, ОбъектJSON);
	
	Возврат Запись.Закрыть();
	
КонецФункции  

Функция ОбъектJSON(СтрокаJSON) Экспорт
	
	Чтение = Новый ЧтениеJSON; 
	Чтение.УстановитьСтроку(СтрокаJSON);
	ОбъектJSON = ПрочитатьJSON(Чтение);
	Чтение.Закрыть();
	
	Возврат ОбъектJSON;
	
КонецФункции


//передает заголовок с типом данных для Телеграм
//Возвращаемое значение:
// строка
// Параметры: 
// Объект - строка   
// КодСостояния - число
Функция ОтветJSON( Объект, КодСостояния = 200) Экспорт
	
	Ответ = Новый HTTPСервисОтвет(КодСостояния);
	
	Ответ.УстановитьТелоИзСтроки(СтрокаJSON(Объект));
	Ответ.Заголовки.Вставить("Content-Type", ТипКонентаJSON());
	
	Возврат Ответ;
	
КонецФункции


Функция ПростойОтвет() Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("Result","Ok");
	
	Возврат ОтветJSON(Результат);
	
КонецФункции    


Функция ОтветОбОшибке(ИнформацияОбОшибке) Экспорт 
	
	ЗаписьЖурналаРегистрации("HTTPСервисы.Ошибка", УровеньЖурналаРегистрации.Ошибка,,,
		ПодробноеПредставлениеОшибки(ИнформацияОбОшибке)); 
		
	Результат = Новый Структура;
	Результат.Вставить("Result","Error");
	Результат.Вставить("ErrorText",КраткоеПредставлениеОшибки(ИнформацияОбОшибке));  
	
	Возврат ОтветJSON(Результат, 500);

КонецФункции    

Процедура ЗаписьЛога(ИмяМетода, Запрос, Ответ) Экспорт   
	
	ДокОбъект = Документы.ВКМ_ВходящийHTTPЗапрос.СоздатьДокумент();  
	ДокОбъект.ИмяМетода = ИмяМетода; 
	ДокОбъект.ТелоЗапроса = Запрос.ПолучитьТелоКакСтроку();
	ДокОбъект.КодСостояния = Ответ.КодСостояния;
	ДокОбъект.Дата = ТекущаяДатаСеанса();   
	
	ДокОбъект.Записать();

	
	
КонецПроцедуры

//Функция СообщениеВТелеграм() Экспорт
//	
//	СообщениеКОтправке = Новый Структура;
//	СообщениеКОтправке.Вставить("chat_id", 6362405545);     //Формат(Строка(6362405545), "ЧГ=0")
//				СообщениеКОтправке.Вставить("method", "sendMessage");

//	СообщениеКОтправке.Вставить("text", "ТЕКСТ"); 

//	
//	Возврат ОтветJSON(СообщениеКОтправке.text);
//	
//КонецФункции


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ТипКонентаJSON()
	Возврат "application/json";
КонецФункции

#КонецОбласти