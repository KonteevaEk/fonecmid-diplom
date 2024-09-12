//НачалоДоработки. Контеева, 05.07.24. Заполнение графика отпусков, проверка длительности, чтобы не превышали 28 календарных дней,  
//построение диаграммы с отпусками на дополнительной форме.

#Область ОбработчикиСобытийФормы
 
 &НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)   
	
	Если НЕ ЗначениеЗаполнено(Объект.Год) Тогда
		
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = "Нужно выбрать год для графика отпусков";
		Сообщение.Сообщить();
		Отказ = Истина;
	 
	Иначе 
	Для Каждого Строка из Объект.ОтпускаСотрудников Цикл   
		
		Если Строка.ДатаОкончания >= КонецГода(Объект.Год) ИЛИ Строка.ДатаНачала <= НачалоГода(Объект.Год) Тогда  
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = СтрШаблон("Даты отпуска сотрудника %1 выходят за пределы года", Строка.Сотрудник);
			Сообщение.Сообщить(); 
			Отказ = Истина; 
		КонецЕсли;  
		
	КонецЦикла;  
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ) 
	
	ПроверкаДлительностиОтпусков();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыОтпускаСотрудников

&НаКлиенте
Процедура ОтпускаСотрудниковПриИзменении(Элемент)   
	
	 ПроверкаДлительностиОтпусков();

 КонецПроцедуры  
 
#КонецОбласти
   
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОткрытьАнализГрафика(Команда)  
	
	ПоместитьТЧВоВременноеХранилищеНаСервере();
	
	ПараметрыФормы = Новый Структура();
	ПараметрыФормы.Вставить("Год", Объект.Дата);
	ПараметрыФормы.Вставить("АдресВХ", Объект.АдресВХ);
	
	ОткрытьФорму("Документ.ВКМ_ГрафикОтпусков.Форма.ФормаАнализГрафика", ПараметрыФормы);
КонецПроцедуры 

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ПроверкаДлительностиОтпусков()
МассивСтрок = Новый Массив;
	
	Для Каждого Строка из Объект.ОтпускаСотрудников Цикл   
		
		СтруктураСтроки = Новый Структура ("Сотрудник, ПериодОтпуска");		
		
		Строка.ПревышениеОтпуска = Ложь;
		ПериодОтпуска = (Строка.ДатаОкончания - Строка.ДатаНачала)/86400  + 1;
		Если ПериодОтпуска > 28 Тогда 
			Строка.ПревышениеОтпуска = Истина;
			
			УсловноеОформлениеДлинногоОтпуска(Строка.ПревышениеОтпуска);
		КонецЕсли;
		
		Если МассивСтрок.Количество() = 0 Тогда 
			СтруктураСтроки.Сотрудник = Строка.Сотрудник; 
			СтруктураСтроки.ПериодОтпуска = ПериодОтпуска;
			МассивСтрок.Добавить(СтруктураСтроки); 
			
		Иначе 
			СотрудникаНет = Истина;
			
			Для а = 0 по МассивСтрок.Количество()-1 Цикл
				Если МассивСтрок.Получить(а).Сотрудник = Строка.Сотрудник тогда
					СотрудникаНет = Ложь;   
					НовыйПериодОтпуска = МассивСтрок.Получить(а).ПериодОтпуска + ПериодОтпуска;     
					МассивСтрок[а].ПериодОтпуска = НовыйПериодОтпуска;    
					
					Если НовыйПериодОтпуска > 28 Тогда 
						Строка.ПревышениеОтпуска = Истина; 
						УсловноеОформлениеДлинногоОтпуска(Строка.ПревышениеОтпуска);
					КонецЕсли; 
					
				КонецЕсли;
				
			КонецЦикла;
			Если СотрудникаНет Тогда
				
				СтруктураСтроки.Сотрудник = Строка.Сотрудник;
				СтруктураСтроки.ПериодОтпуска = ПериодОтпуска;  
				МассивСтрок.Добавить(СтруктураСтроки); 
			КонецЕсли;
			
		КонецЕсли; 
		
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура  УсловноеОформлениеДлинногоОтпуска(ФактПревышенияОтпуска)  
	
	Если ФактПревышенияОтпуска Тогда 
		
		УсловноеОформление.Элементы.Очистить();
		
		Элемент = УсловноеОформление.Элементы.Добавить();  
		ОформлениеЦветФона = Элемент.Оформление.Элементы.Найти("ЦветФона");
		ОформлениеЦветФона.Значение = WebЦвета.Розовый;
		ОформлениеЦветФона.Использование = Истина;
		
		НастройкаОтбора = Элемент.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
		НастройкаОтбора.ЛевоеЗначение = Новый ПолеКомпоновкиДанных("Объект.ОтпускаСотрудников.ПревышениеОтпуска");
		НастройкаОтбора.ВидСравнения = ВидСравненияКомпоновкиДанных.Равно;
		НастройкаОтбора.ПравоеЗначение = Истина;
		
		ПолеЭлемента1 = Элемент.Поля.Элементы.Добавить();
		ПолеЭлемента1.Поле = Новый ПолеКомпоновкиДанных("ОтпускаСотрудниковСотрудник");
		ПолеЭлемента1.Использование = Истина;  
		
		ПолеЭлемента2 = Элемент.Поля.Элементы.Добавить();
		ПолеЭлемента2.Поле = Новый ПолеКомпоновкиДанных("ОтпускаСотрудниковДатаОкончания");
		ПолеЭлемента2.Использование = Истина;
		
		ПолеЭлемента3 = Элемент.Поля.Элементы.Добавить();
		ПолеЭлемента3.Поле = Новый ПолеКомпоновкиДанных("ОтпускаСотрудниковНомерСтроки");
		ПолеЭлемента3.Использование = Истина;   
		
		ПолеЭлемента4 = Элемент.Поля.Элементы.Добавить();
		ПолеЭлемента4.Поле = Новый ПолеКомпоновкиДанных("ОтпускаСотрудниковДатаНачала");
		ПолеЭлемента4.Использование = Истина;   
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПоместитьТЧВоВременноеХранилищеНаСервере()   
	
	ТаблицаЗначенийОтпускаСотрудников = Объект.ОтпускаСотрудников.Выгрузить(); 
	Объект.АдресВХ = ПоместитьВоВременноеХранилище(ТаблицаЗначенийОтпускаСотрудников); 
	
КонецПроцедуры

#КонецОбласти
            
//Конец доработки				   
