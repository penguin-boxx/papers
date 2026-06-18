%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  LaTeX class for preparing papers to "SPIIRAS Proceedings"
%%  (under MikTeX 2.9 platform)
%%  charset=utf8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\NeedsTeXFormat{LaTeX2e}[1998/12/01]
\ProvidesClass{SPIIRAS_Proceedings}[2017/12/07 alpha v3.3
LaTeX class for preparing papers to "SPIIRAS Proceedings"]
\ClassWarningNoLine{SPIIRAS_Proceedings}{This class requires MikTeX 2.9}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\let\if@openbib\iffalse
\DeclareOption{openbib}{\let\if@openbib\iftrue}

\ProcessOptions
\LoadClass[a5paper]{extarticle} % стандартный класс
\RequirePackage[utf8]{inputenc} %
\RequirePackage[english,russian]{babel} % русификация
\RequirePackage{tempora}
\RequirePackage[T2A]{fontenc} % шрифты
\RequirePackage[reqno,tbtags]{amsmath} % расширенные возможности для задания формул reqno, 
\RequirePackage{amsfonts,amssymb,mathrsfs} % расширенные возможности написания математических формул
\RequirePackage{graphicx} % добавление рисунков в статью
\RequirePackage{cite} % объединение перечислений ссылок на элементы литерытуры в тексте статьи
\RequirePackage{url} % корректное отображение и перенос ссылок на интернет ресурсы
\RequirePackage{listings} % представление исходного кода, алгоритмов, включает в себя пакет algorithm
\RequirePackage[font=small,format=plain,labelsep=period,justification=centering, skip=0pt]{caption}
\RequirePackage{verbatim} % для возможности закомментировать кусок текста \begin{comment} ... \end{comment}
\RequirePackage{calc} % расширенные возможности арифметических операций
\RequirePackage[colorlinks = true,linkcolor = black,urlcolor = blue,citecolor = black]{hyperref}
\RequirePackage{microtype} % улучшение общего вида текста
\RequirePackage{tabularx} % улучшенная поддержка таблиц
\RequirePackage{longtable} % поддержка таблиц на несколько страниц
\RequirePackage{setspace} % для однострочного интервала
\RequirePackage[explicit]{titlesec} % форматирование заголовок секций
%///////////////////////////////////////////////////////%

% 108--170mm page margins

\oddsidemargin 0 mm
\textwidth 108 mm
\topmargin 0 mm
\headheight 0 mm
\headsep 0 mm
\textheight 170 mm
\footskip 7mm
\hoffset -5mm
\voffset -5mm

%///////////////////////////////////////////////////////%

% Дополнительные переменные для оформления статьи

\pdfpkresolution 5000 %полиграфическое качество печати
\parindent=1cm %красная строка
\pagestyle{empty} %пустые колонтитулы
\tolerance 400 %коэффициент чувствителньости при переносе слов
\urlstyle{same} %ссылка печатаются тем же шрифтом, что и текст документа
% запрет висячих строк
\clubpenalty=10000
\widowpenalty=10000
\singlespacing % однострочный интервал в тексте


%///////////////////////////////////////////////////////%

% Листинги и Алгоритмы 
% far

\lstset{breaklines=true,language=C,showstringspaces=false,breaklines=true,xleftmargin=\parindent,captionpos=b,basicstyle=\fontsize{9pt}{10}\sffamily,basewidth=0.42em}

%///////////////////////////////////////////////////////%

%Перечни и Списки
\renewenvironment{itemize}%
      {\begin{list}{\nobreak--\hfil}{\setlength{\labelwidth}{0pt}
  \setlength{\labelsep}{5pt}
  \setlength{\leftmargin}{0pt}
  \setlength{\itemindent}{\parindent}
  \addtolength{\itemindent}{\labelwidth}
  \addtolength{\itemindent}{\labelsep}
  \setlength{\listparindent}{\parindent}
  \setlength{\itemsep}{0pt}
  \setlength{\parsep}{0mm}
  \setlength{\topsep}{0mm}
  \setlength{\partopsep}{0mm}}}{\end{list}}
 
\renewenvironment{enumerate}%
{	
	\begin{list}{\nobreak\strut\smash{\parbox[t]\labelwidth{\raggedright{\arabic{enumi}.}}}}
	{
		\setlength{\labelwidth}{0pt}
		\setlength{\leftmargin}{0pt}
		\setlength{\labelwidth}{\widthof{\arabic{enumi}.}}
		\setlength{\labelsep}{-5pt}		
		\setlength{\itemindent}{\parindent}
		%\addtolength{\itemindent}{\labelwidth}
		\addtolength{\itemindent}{10pt}
		\addtolength{\labelsep}{\labelwidth}
		\setlength{\listparindent}{\parindent}
		\setlength{\itemsep}{0pt}
		\setlength{\parsep}{0mm}
		\setlength{\topsep}{0mm}
		\setlength{\partopsep}{0mm}
		\usecounter{enumi}
	}
}{\end{list}} 


%///////////////////////////////////////////////////////%
%%  Сколь угодно жидкие строки
\sloppy

%%\setlength\parskip{2\p@ \@plus \p@}
\setlength\parskip{0pt}

%///////////////////////////////////////////////////////%

%%  Знаки нестрогих равенств (как принято у нас)
\def\le{\leqslant}
\def\leq{\leqslant}
\def\ge{\geqslant}
\def\geq{\geqslant}

%///////////////////////////////////////////////////////%

%%  Список литературы
\def\refnameRus{\normalsize \textbf{Литература}}
\def\refnameEng{\normalsize \textbf{References}}
\newcounter{aux@counter}
\def\thebibliographyRus#1{%
\refstepcounter{aux@counter}%
\vskip 8pt
\sectionBib*{\refnameRus}
\def\@biblabel##1{{\select@language{russian}##1.\hfill \hskip 0.45cm}}
\footnotesize
\list
 {
 \@biblabel{\arabic{enumi}}}{\settowidth\labelwidth{\@biblabel{#1}}\leftmargin\labelwidth
 \advance\leftmargin\labelsep
 \usecounter{enumi}}
 \setlength{\parskip}{-1pt}
 \def\newblock{\hskip .11em \@plus .33em \@minus .07em}%
 \sloppy\clubpenalty4000\widowpenalty4000
 \sfcode`\.=1000\relax
 \def\makelabel##1{\hfil ##1}
}

\def\thebibliographyEng#1{%
\refstepcounter{aux@counter}%
\vskip 8pt
\sectionBib*{\refnameEng}
\def\@biblabel##1{{\select@language{russian}##1.\hfill \hskip 0.45cm}}
\footnotesize
\list
 {\@biblabel{\arabic{enumi}}}{\settowidth\labelwidth{\@biblabel{#1}}\leftmargin\labelwidth
 \advance\leftmargin\labelsep
 \usecounter{enumi}}
 \setlength{\parskip}{-1pt}
 \def\newblock{\hskip .11em \@plus .33em \@minus .07em}%
 \sloppy\clubpenalty4000\widowpenalty4000
 \sfcode`\.=1000\relax
 \def\makelabel##1{\hfil ##1}
}

%///////////////////////////////////////////////////////%

%%  Макросы для определения заголовка
%%  УДК
\def\udk#1{\gdef\@udk{#1}} %% УДК

%% DOI
\def\doi#1{\gdef\@doi{#1}} %% DOI
\global\let\@doi\@empty

%%  Авторы
\def\authorsTitleRus#1{\gdef\@authorsTitleRus{#1}} % авторы в заголовке на руском языке
\def\authorsTitleEng#1{\gdef\@authorsTitleEng{#1}} % авторы в заголовке на английском языке

\def\authorsRus#1{\gdef\@authorsRus{#1}} % авторы в тексте на русском языке
\def\authorsEng#1{\gdef\@authorsEng{#1}} % авторы в тексте на английском языке
%%  Название статьи
%\def\title#1{\gdef\@title{#1}} %% название статьи в заголовке
\def\titleRus#1{\gdef\@titleRus{#1}} %% название статьи на русском языке
\def\titleEng#1{\gdef\@titleEng{#1}} %% название статьи на английском языке
%%  Аннотация
\long\def\abstractRus#1{\gdef\@abstractRus{#1}} % текст аннотации на русском языке
\long\def\abstractEng#1{\gdef\@abstractEng{#1}} % текст аннотации на английском языке
%%  Ключевые слова
\def\keywordsRus#1{\gdef\@keywordsRus{#1}}% Ключевые слова на русском языке
\def\keywordsEng#1{\gdef\@keywordsEng{#1}} % Ключевые слова на английском языке

%///////////////////////////////////////////////////////%

\newcommand{\smallcapsfake}[1]{\fontsize{2.8mm}{5mm}\selectfont\expandafter\MakeUppercase\expandafter{#1} \normalsize\normalfont}

%%  Шапка
\renewcommand{\maketitle}{
\noindent\footnotesize\textbf{УДК}~\@udk\ifx\@doi\@empty\relax\else\hfill\footnotesize\textbf{DOI}~\@doi\fi
\begin{center}
\normalsize\@authorsTitleRus\\%[3ex]
\normalsize\bfseries\MakeUppercase{\@titleRus}\\[8pt] %
\normalsize\normalfont
\end{center}
\rule{\textwidth}{0.5pt}
\textit{\@authorsRus}~\textbf{\@titleRus.}\\
{\hspace*{0.5cm}\textbf{Аннотация.}}~{\hyphenpenalty=10000\setlength{\parindent}{0.5cm} \@abstractRus}\\
\hspace*{0.5cm}\textbf{Ключевые слова:}~\@keywordsRus \\[-4pt] %
\rule{\textwidth}{0.5pt} \\[-2pt] %
}

\newcommand{\makeengtitle}{
\noindent\footnotesize\ifx\@doi\@empty\relax\else\hfill\footnotesize\textbf{DOI}~\@doi\fi
\begin{center}
    \normalsize\@authorsTitleEng\\%[3ex]
    \normalsize\bfseries\MakeUppercase{\@titleEng}\\[8pt] %
    \normalsize\normalfont
\end{center}
\rule{\textwidth}{0.5pt}
\textit{\@authorsEng}~\textbf{\@titleEng.}\\
{\hspace*{0.5cm}\textbf{Abstract.}}~{\hyphenpenalty=10000\setlength{\parindent}{0.5cm} \@abstractEng}\par
\hspace{-\parindent}\hspace*{0.5cm}\textbf{Keywords:}~\@keywordsEng \\[-4pt] % %% some magic to make last abstract paragraph look good 
\rule{\textwidth}{0.5pt} \\[-2pt] %
}

%///////////////////////////////////////////////////////%

%%  Информация об Авторах
\newenvironment{aboutAuthors}
{\vskip 4pt\parindent=0pt\footnotesize
}

%///////////////////////////////////////////////////////%

%%  Реферат и Summary

\long\def\summaryRus#1{\long\gdef\@summaryRus{#1}}% Реферат на русском языке
\long\def\summaryEng#1{\long\gdef\@summaryEng{#1}} % Реферат на английском языке
\newlength{\summaryRusLenght}
\newlength{\summaryEngLenght}
\newlength{\halfoftextheight}
\halfoftextheight=0.45\textheight

\newcommand{\makeSummary}{
\settoheight{\summaryRusLenght}{\vbox{\@summaryRus}}
\settoheight{\summaryEngLenght}{\vbox{\@summaryEng}}
\newpage
\begin{center}
\normalsize\textbf{РЕФЕРАТ}\\[8pt] %
\normalsize\normalfont
\end{center}
\normalsize
\textit{\@authorsRus}~\textbf{\@titleRus.}\\[-10pt] %
\small\@summaryRus
\ifnum \summaryRusLenght>\halfoftextheight
	\newpage	
\fi
%\ifnum \summaryRusLenght<\halfoftextheight
%	\ifnum \summaryEngLenght<\halfoftextheight
%		\\
%	\fi
%\else
%\newpage
%\fi
\begin{center}
\normalsize\textbf{SUMMARY}\\[8pt] %
\normalsize\normalfont
\end{center}
\normalsize
\textit{\@authorsEng}~\textbf{\@titleEng.}\\[-10pt] %
\small\@summaryEng
}

%///////////////////////////////////////////////////////%

%%  Точки после номеров теорем
\def\afterthmseparator{.}
\def\@begintheorem#1#2{%
\setlength{\topsep}{1pt}%
\setlength{\partopsep}{0mm}%
\trivlist\item[\hskip\labelsep{\rm
#1\ #2\unskip\afterthmseparator}]\itshape}
\def\@opargbegintheorem#1#2#3{%
\setlength{\topsep}{1pt}%
\setlength{\partopsep}{0mm}%
\trivlist\item[\hskip\labelsep{\rm
#1\ #2\ {\rm{#3}}\afterthmseparator}]\ditshape}

%///////////////////////////////////////////////////////%

%%  Раздел
\newcommand\sectionBib{\@startsection{sectionBib}{1}{\parindent}%
{0pt}%
{0pt}%
{\normalfont\normalsize\bfseries}}

\usepackage[explicit]{titlesec}
\titleformat{\section}[runin]{\normalfont\normalsize\bfseries}{\thesection.}{.5em}
{\normalfont\normalsize\bfseries#1}[.\;]
\titlespacing{\section}
{\parindent}{0pt}{0pt}

%///////////////////////////////////////////////////////%
%%  Подраздел

\titleformat{\subsection}[runin]{\normalfont\normalsize\bfseries}{\thesubsection.}{.5em}
{\normalfont\normalsize\bfseries#1}[.\;]
\titlespacing{\subsection}
{\parindent}{0pt}{0pt}

%///////////////////////////////////////////////////////%
%% Подподраздел
\titleformat{\subsubsection}[runin]{\normalfont\normalsize\bfseries}{\thesubsubsection.}{.5em}
{\normalfont\normalsize\bfseries#1}[.\;]
\titlespacing{\subsubsection}
{\parindent}{0pt}{0pt}

%///////////////////////////////////////////////////////%

%%  Теорема
\newtheorem{theorem}{\hspace{\parindent}\sl{Т\,е\,о\,р\,е\,м\,а\,}}

%%  Следствие
\newtheorem{corollary}{\hspace{\parindent}\sl{С\,л\,е\,д\,с\,т\,в\,и\,е\,}}

%%  Лемма
\newtheorem{lemma}{\hspace{\parindent}\sl{Л\,е\,м\,м\,а\,}}

%%  Утверждение
\newtheorem{statement}{\hspace{\parindent}\sl{У\,т\,в\,е\,р\,ж\,д\,е\,н\,и\,е\,}}

%%  Предложение
\newtheorem{proposition}{\hspace{\parindent}\sl{П\,р\,е\,д\,л\,о\,ж\,е\,н\,и\,е\,}}

%%  Алгоритм
%\newtheorem{algorithm}{\hspace{\parindent}\sl{А\,л\,г\,о\,р\,и\,т\,м\,}}

%%  Определение
\newtheorem{definition}{\hspace{\parindent}\sl{О\,п\,р\,е\,д\,е\,л\,е\,н\,и\,е\,}}

%%  Задача
\newtheorem{problem}{\hspace{\parindent}\sl{З\,а\,д\,а\,ч\,а\,}}

%%  Доказательство
\newenvironment{proof}
{\vspace{1pt}\par{\sl%
Д\,о\,к\,а\,з\,а\,т\,е\,л\,ь\,с\,т\,в\,о.\,\ }}%
{\noindent\vspace{1pt}}

%%  Доказательство теоремы
\newenvironment{proofoftheorem}[1]
{\vspace{1pt}\par{\sl%
Д\,о\,к\,а\,з\,а\,т\,е\,л\,ь\,с\,т\,в\,о\, т\,е\,о\,р\,е\,м\,ы\, #1.}}%
{\noindent\vspace{1pt}}

%%  Доказательство следствия
\newenvironment{proofofcorollary}[1]
{\vspace{1pt}\par{\sl%
Д\,о\,к\,а\,з\,а\,т\,е\,л\,ь\,с\,т\,в\,о\, с\,л\,е\,д\,с\,т\,в\,и\,я\, #1.}}%
{\noindent\vspace{1pt}}

%%  Доказательство леммы
\newenvironment{proofoflemma}[1]
{\vspace{1pt}\par{\sl%
Д\,о\,к\,а\,з\,а\,т\,е\,л\,ь\,с\,т\,в\,о\, л\,е\,м\,м\,ы\, #1.}}%
{\noindent\vspace{1pt}}

%%  Доказательство утверждения
\newenvironment{proofofstatement}[1]
{\vspace{1pt}\par{\sl%
Д\,о\,к\,а\,з\,а\,т\,е\,л\,ь\,с\,т\,в\,о\, у\,т\,в\,е\,р\,ж\,д\,е\,н\,и\,я\, #1.}}%
{\noindent\vspace{1pt}}

%%  Доказательство предложения
\newenvironment{proofofproposition}[1]
{\vspace{1pt}\par{\sl%
Д\,о\,к\,а\,з\,а\,т\,е\,л\,ь\,с\,т\,в\,о\, п\,р\,е\,д\,л\,о\,ж\,е\,н\,и\,я\, #1.}}%
{\noindent\vspace{1pt}}

%%  Алгоритм
\newtheorem{alg}{\hspace{\parindent}\sl{А\,л\,г\,о\,р\,и\,т\,м\,}}%
\newenvironment{algorithm}[1][\unskip]{\begin{alg}[#1]\em}{\end{alg}}%
\def\thealgorithm{\thealg}

%%  Замечание
\newtheorem{rem}{\hspace{\parindent}\sl{З\,а\,м\,е\,ч\,а\,н\,и\,е}}%
\newenvironment{remark}[1][\unskip]{\begin{rem}[#1]\em}{\end{rem}}%
\def\theremark{\therem}

%%  Пример
\newtheorem{exmpl}{\hspace{\parindent}\sl{П\,р\,и\,м\,е\,р\,}}%
\newenvironment{example}[1][\unskip]{\begin{exmpl}[#1]\em}{\end{exmpl}}%
\def\theexample{\theexmpl}


%%  Ссылка на элемент перечня
\def\itemref#1{{\rm\ref{#1})}}

%%  В окружении multline сдвиг=0
\multlinegap=0pt


%% Добавим правило, что нельзя переносить аббревиатуры

\hyphenation{СПИИРАН}

\endinput
