//НачалоДоработки. Контеева, 06.05.24. 
//Начисление з/п
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
	#Область ОбработчикиСобытий
	
	Процедура ОбработкаПроведения(Отказ, РежимПроведения) 
		
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;   
		Движения.ВКМ_ФактическиеОтпуска.Записывать = Истина;

		Движения.ВКМ_ВзаиморасчетыССотрудниками.Очистить();  
		
		СформироватьДвиженияОснНачисления();   
		СформироватьДвиженияУдержания();   
		
		РассчитатьОкладИВыполненныеРаботы();     
		РассчитатьОтпуск(); 
		РассчитатьНДФЛ();	
		
	КонецПроцедуры
	
	#КонецОбласти
	
	#Область СлужебныеПроцедурыИФункции
	
	Процедура СформироватьДвиженияОснНачисления()  
		
		Для Каждого Строка Из Начисления Цикл  
			
			Движение = Движения.ВКМ_ОсновныеНачисления.Добавить();
			Движение.ПериодРегистрации = Дата;
			Движение.ВидРасчета = Строка.ВидРасчета;
			Движение.ПериодДействияНачало = Строка.ДатаНачала;
			Движение.ПериодДействияКонец = Строка.ДатаОкончания;  
			Движение.Сотрудник = Строка.Сотрудник;
			Движение.ГрафикРаботы = Строка.ГрафикРаботы;   
			
			Если Строка.ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск Тогда     
				Движение.БазовыйПериодНачало = НачалоМесяца(ДобавитьМесяц(Строка.ДатаНачала, -12));
				Движение.БазовыйПериодКонец = КонецМесяца(ДобавитьМесяц(Строка.ДатаОкончания, -1)); 
				
				// регистр ВКМ_ФактическиеОтпуска 
				Движение = Движения.ВКМ_ФактическиеОтпуска.Добавить();
				Движение.Период = Дата;
				Движение.Сотрудник = Строка.Сотрудник;
				Движение.ОтпускФакт = (Строка.ДатаОкончания-Строка.ДатаНачала+86400)/86400;
				
			КонецЕсли;	
			
		КонецЦикла; 
		
		Движения.ВКМ_ОсновныеНачисления.Записать();
		
	КонецПроцедуры  
	
	Процедура СформироватьДвиженияУдержания()  
		
		СотрудникЕсть = Новый Массив;
		
		Для Каждого Строка Из Начисления Цикл 
			
			ПроверкаСотрудника = СотрудникЕсть.Найти(Строка.Сотрудник); 
			
			Если ПроверкаСотрудника = Неопределено Тогда 
				Движение = Движения.ВКМ_Удержания.Добавить();
				Движение.ПериодРегистрации = Дата;
				Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
				Движение.ПериодДействияНачало = Строка.ДатаНачала;
				Движение.ПериодДействияКонец = Строка.ДатаОкончания;  
				Движение.Сотрудник = Строка.Сотрудник;
				Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
				Движение.БазовыйПериодКонец = КонецМесяца(Дата);  
				
				СотрудникЕсть.Добавить(Строка.Сотрудник);  
				
			КонецЕсли;
			
		КонецЦикла; 
		
		Движения.ВКМ_Удержания.Записать();
		
	КонецПроцедуры  
	
	Процедура РассчитатьОкладИВыполненныеРаботы()    
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.ЗначениеФактическийПериодДействия КАК Факт,
		|	ВКМ_ОсновныеНачисленияДанныеГрафика.ЗначениеПериодДействия КАК План,
		|	ЕСТЬNULL(ВКМ_УсловияОплатыСотрудниковСрезПоследних.Оклад, 0) КАК Оклад,
		|	ЕСТЬNULL(ВКМ_ВыполненныеСотрудникомРаботыОбороты.СуммаКОплатеОборот, 0) КАК СуммаКОплатеЗаРаботы
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
		|			Регистратор = &Ссылка
		|				И ВидРасчета = &ВидРасчета) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(
		|				&Период,
		|				Сотрудник В
		|					(ВЫБРАТЬ
		|						ОсновныеНачисления.Сотрудник КАК Сотрудник
		|					ИЗ
		|						РегистрРасчета.ВКМ_ОсновныеНачисления КАК ОсновныеНачисления
		|					ГДЕ
		|						ОсновныеНачисления.Регистратор = &Ссылка)) КАК ВКМ_УсловияОплатыСотрудниковСрезПоследних
		|		ПО ВКМ_ОсновныеНачисленияДанныеГрафика.Сотрудник = ВКМ_УсловияОплатыСотрудниковСрезПоследних.Сотрудник
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ВКМ_ВыполненныеСотрудникомРаботы.Обороты(
		|				&НачалоПериода,
		|				&КонецПериода,
		|				Месяц,
		|				Сотрудник В
		|					(ВЫБРАТЬ
		|						ОсновныеНачисления.Сотрудник КАК Сотрудник
		|					ИЗ
		|						РегистрРасчета.ВКМ_ОсновныеНачисления КАК ОсновныеНачисления
		|					ГДЕ
		|						ОсновныеНачисления.Регистратор = &Ссылка)) КАК ВКМ_ВыполненныеСотрудникомРаботыОбороты
		|		ПО ВКМ_ОсновныеНачисленияДанныеГрафика.Сотрудник = ВКМ_ВыполненныеСотрудникомРаботыОбороты.Сотрудник";
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.УстановитьПараметр("Период", Дата);
		Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад); 
		Запрос.УстановитьПараметр("НачалоПериода", НачалоМесяца(Дата));
		Запрос.УстановитьПараметр("КонецПериода", КонецМесяца(Дата));
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Выборка = РезультатЗапроса.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1];   
			Движение.Оклад = Выборка.Оклад;
			
			Если Выборка.План = 0 Тогда
				Движение.Начислено = 0;
				
			Иначе
				Движение.Начислено = Выборка.Оклад * Выборка.Факт / Выборка.План + Выборка.СуммаКОплатеЗаРаботы;  
			КонецЕсли;
			
			Движение.КоличествоРабочихДней = Выборка.Факт; 
			
			// регистр ВКМ_ВзаиморасчетыССотрудниками Приход
			ДвижениеВз = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
			ДвижениеВз.ВидДвижения = ВидДвиженияНакопления.Приход;
			ДвижениеВз.Период = Дата;
			ДвижениеВз.Сотрудник = Движение.Сотрудник;
			ДвижениеВз.Сумма = Движение.Начислено;
			
		КонецЦикла;  
		
		Движения.ВКМ_ОсновныеНачисления.Записать(, Истина);
		
	КонецПроцедуры   
	
	Процедура РассчитатьОтпуск()  
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_ОсновныеНачисления.НомерСтроки КАК НомерСтроки,
		|	ЕСТЬNULL(ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.НачисленоБаза, 0) КАК БазаОсн,
		|	ЕСТЬNULL(ВКМ_ОсновныеНачисленияБазаВКМ_ДополнительныеНачисления.НачисленоБаза, 0) КАК БазаДоп,
		|	ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.КоличествоРабочихДнейБаза КАК КоличествоРабочихДнейБаза,
		|	ЕСТЬNULL(ВКМ_ОсновныеНачисленияДанныеГрафика.ЗначениеФактическийПериодДействия, 0) КАК Факт
		|ИЗ
		|	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.БазаВКМ_ОсновныеНачисления(
		|				&Измерения,
		|				&Измерения,
		|				,
		|				ВидРасчета = &Отпуск
		|					И Регистратор = &Ссылка) КАК ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления
		|		ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.НомерСтроки
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.БазаВКМ_ДополнительныеНачисления(
		|				&Измерения,
		|				&Измерения,
		|				,
		|				ВидРасчета = &Отпуск
		|					И Регистратор = &Ссылка) КАК ВКМ_ОсновныеНачисленияБазаВКМ_ДополнительныеНачисления
		|		ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияБазаВКМ_ДополнительныеНачисления.НомерСтроки
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(Регистратор = &Ссылка) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
		|		ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки
		|ГДЕ
		|	ВКМ_ОсновныеНачисления.Регистратор = &Ссылка
		|	И ВКМ_ОсновныеНачисления.ВидРасчета = &Отпуск";
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);
		Запрос.УстановитьПараметр("Отпуск", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск);
		
		Измерения = Новый Массив;
		Измерения.Добавить("Сотрудник");
		
		Запрос.УстановитьПараметр("Измерения", Измерения);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Выборка = РезультатЗапроса.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1];   
			Движение.КоличествоРабочихДней = Выборка.Факт;
			
			Если Выборка.КоличествоРабочихДнейБаза = NULL Тогда        
				Движение.Начислено = 0;
				Продолжить;
			Иначе
				Движение.Начислено = (Выборка.БазаОсн + Выборка.БазаДоп) / Выборка.КоличествоРабочихДнейБаза * Выборка.Факт; 
			КонецЕсли;
			
			// регистр ВКМ_ВзаиморасчетыССотрудниками Приход
			ДвижениеВз = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
			ДвижениеВз.ВидДвижения = ВидДвиженияНакопления.Приход;
			ДвижениеВз.Период = Дата;
			ДвижениеВз.Сотрудник = Движение.Сотрудник;
			ДвижениеВз.Сумма = Движение.Начислено;
		КонецЦикла;  
		
		Движения.ВКМ_ОсновныеНачисления.Записать(, Истина);
		
	КонецПроцедуры  
	
	Процедура РассчитатьНДФЛ() 
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_Удержания.НомерСтроки КАК НомерСтроки,
		|	ВКМ_Удержания.Сотрудник КАК Сотрудник,
		|	ЕСТЬNULL(ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.НачисленоБаза, 0) КАК НачисленоБаза,
		|	ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.Регистратор КАК Регистратор,
		|	ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.РегистраторРазрез КАК РегистраторРазрез
		|ИЗ
		|	РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания.БазаВКМ_ОсновныеНачисления(
		|				&Измерения,
		|				&Измерения,
		|				&Разрезы,
		|				Регистратор = &Ссылка
		|					И ВидРасчета = &Удержание) КАК ВКМ_УдержанияБазаВКМ_ОсновныеНачисления
		|		ПО ВКМ_Удержания.НомерСтроки = ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.НомерСтроки
		|ГДЕ
		|	ВКМ_Удержания.Регистратор = &Ссылка
		|	И ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.РегистраторРазрез = ВКМ_УдержанияБазаВКМ_ОсновныеНачисления.Регистратор";
		
		Запрос.УстановитьПараметр("Ссылка", Ссылка);   
		Запрос.УстановитьПараметр("Удержание",  ПланыВидовРасчета.ВКМ_Удержания.НДФЛ);  
		
		Измерения = Новый Массив;
		Измерения.Добавить("Сотрудник"); 
		
		Разрезы = Новый Массив;
		Разрезы.Добавить("Регистратор");
		
		Запрос.УстановитьПараметр("Измерения", Измерения); 
		Запрос.УстановитьПараметр("Разрезы", Разрезы);  
		
		РезультатЗапроса = Запрос.Выполнить();
		
		Выборка = РезультатЗапроса.Выбрать();
		
		Пока Выборка.Следующий() Цикл
			ДвижениеУдержание = Движения.ВКМ_Удержания[Выборка.НомерСтроки-1];   
			ДвижениеУдержание.НДФЛ = Выборка.НачисленоБаза/100*13; 
			Движения.ВКМ_Удержания.Записать(, Истина);
			
			// регистр ВКМ_ВзаиморасчетыССотрудниками Расход
			ДвижениеВз = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
			ДвижениеВз.ВидДвижения = ВидДвиженияНакопления.Расход;
			ДвижениеВз.Период = Дата;
			ДвижениеВз.Сотрудник = Выборка.Сотрудник;
			ДвижениеВз.Сумма = ДвижениеУдержание.НДФЛ;   
			
		КонецЦикла;  
		
	КонецПроцедуры
	
	#КонецОбласти
	
#КонецЕсли

//Конец доработки