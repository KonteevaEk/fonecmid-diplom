//НачалоДоработки. Контеева, 06.05.24. Проверка при проведении документа, 
//что выбран договор Обслуживания и что дата документа лежит между датой начала и датой окончания действия договора

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
	#Область ОбработчикиСобытий
	
	
	Процедура ОбработкаПроведения(Отказ, РежимПроведения)
		
		ДоговорСсылка = ВКМ_Договор;
		ЗначенияРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ДоговорСсылка, 
		"ВидДоговора, ВКМ_НачалоДействия, ВКМ_КонецДействия, ВКМ_ЧасоваяСтавка");
		
		ВидДоговора = ЗначенияРеквизитов.ВидДоговора;
		НачалоДоговора = ЗначенияРеквизитов.ВКМ_НачалоДействия;
		КонецДоговора = ЗначенияРеквизитов.ВКМ_КонецДействия;
		СтоимостьЧасаПоДог = ЗначенияРеквизитов.ВКМ_ЧасоваяСтавка;
		
		КоличествоЧасовВДок = 0;
		Для Каждого ТекСтрокаРаботы Из ВКМ_ВыполненныеРаботы Цикл
			КоличествоЧасовВДок = КоличествоЧасовВДок + ТекСтрокаРаботы.ВКМ_ЧасыКОплате;
		КонецЦикла;
		
		Если ВидДоговора <> Перечисления.ВидыДоговоровКонтрагентов.ВКМ_Обслуживание Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Нужно выбрать договор обслуживания";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЕсли;
		
		Если Дата > КонецДня(КонецДоговора) ИЛИ Дата < НачалоДня(НачалоДоговора) Тогда
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Договор не действителен на дату документа";
			Сообщение.Сообщить();
			Отказ = Истина;
		КонецЕсли;
		
		Движения.ВКМ_ВыполненныеКлиентуРаботы.Записывать = Истина;  
		Движения.ВКМ_ВыполненныеСотрудникомРаботы.Записывать = Истина;
		
		// регистр ВКМ_ВыполненныеКлиентуРаботы Приход
		ДвижениеКл = Движения.ВКМ_ВыполненныеКлиентуРаботы.Добавить();
		ДвижениеКл.ВидДвижения = ВидДвиженияНакопления.Приход;
		ДвижениеКл.Период = ВКМ_ДатаПроведенияРабот;       
		ДвижениеКл.ВКМ_Клиент = ВКМ_Клиент;
		ДвижениеКл.ВКМ_Договор = ВКМ_Договор;
		ДвижениеКл.ВКМ_КоличествоЧасов = КоличествоЧасовВДок;
		ДвижениеКл.ВКМ_СуммаКОплате = КоличествоЧасовВДок*СтоимостьЧасаПоДог;    
		
		// регистр ВКМ_ВыполненныеСотрудникомРаботы Приход
		ДвижениеСотр = Движения.ВКМ_ВыполненныеСотрудникомРаботы.Добавить();
		ДвижениеСотр.ВидДвижения = ВидДвиженияНакопления.Приход;
		ДвижениеСотр.Период = ВКМ_ДатаПроведенияРабот;        
		ДвижениеСотр.Сотрудник = ВКМ_Специалист;
		ДвижениеСотр.ЧасовКОплате = КоличествоЧасовВДок;  
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВКМ_УсловияОплатыСотрудниковСрезПоследних.ПроцентОтРабот КАК ПроцентОтРабот
		|ИЗ
		|	РегистрСведений.ВКМ_УсловияОплатыСотрудников.СрезПоследних(&Период, Сотрудник = &Сотрудник) КАК ВКМ_УсловияОплатыСотрудниковСрезПоследних";
		
		Запрос.УстановитьПараметр("Период", Дата);
		Запрос.УстановитьПараметр("Сотрудник", ВКМ_Специалист);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			ПроцентОтРабот = ВыборкаДетальныеЗаписи.ПроцентОтРабот;
		КонецЦикла; 
		
		Если ПроцентОтРабот = Неопределено Тогда 
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = "Не заполнен процент оплаты сотрудника";
			Сообщение.Сообщить();
			Отказ = Истина;
		Иначе 
			ДвижениеСотр.СуммаКОплате = КоличествоЧасовВДок*СтоимостьЧасаПоДог*ПроцентОтРабот / 100; 

		КонецЕсли;
		
	КонецПроцедуры
	
	#КонецОбласти
	
#КонецЕсли

//Конец доработки