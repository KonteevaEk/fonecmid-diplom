//НачалоДоработки. Контеева, 06.05.24. 

#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура Заполнить(Команда)
	ЗаполнитьНаСервере();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ЗаполнитьНаСервере()

	Если НЕ Объект.Ссылка = Документы.ВКМ_ВыплатаЗарплаты.ПустаяСсылка() Тогда 
	ОбъектФормы = РеквизитФормыВЗначение("Объект");
	ОбъектФормы.ОчисткаРегистра();
	
	ЗначениеВРеквизитФормы(ОбъектФормы, "Объект");   
	
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.Сотрудник КАК Сотрудник,
	|	ВКМ_ВзаиморасчетыССотрудникамиОстатки.СуммаОстаток КАК СуммаОстаток
	|ИЗ
	|	РегистрНакопления.ВКМ_ВзаиморасчетыССотрудниками.Остатки(&Дата) КАК ВКМ_ВзаиморасчетыССотрудникамиОстатки";
	
	Запрос.УстановитьПараметр("Дата", Новый Граница(КонецДня(Объект.Дата), ВидГраницы.Включая));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Объект.Выплаты.Очистить();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		НоваяСтрока = Объект.Выплаты.Добавить();
		НоваяСтрока.Сотрудник=ВыборкаДетальныеЗаписи.Сотрудник;
		НоваяСтрока.Сумма=ВыборкаДетальныеЗаписи.СуммаОстаток;
	КонецЦикла;  
	
КонецПроцедуры      

#КонецОбласти

//Конец доработки
