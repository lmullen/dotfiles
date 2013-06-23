%%
%% This is file `brandeis-dissertation.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% brandeis-dissertation.dtx  (with options: `class')
%% 
%% IMPORTANT NOTICE:
%% 
%% For the copyright see the source file.
%% 
%% Any modified versions of this file must be renamed
%% with new filenames distinct from brandeis-dissertation.cls.
%% 
%% For distribution of the original source see the terms
%% for copying and modification in the file brandeis-dissertation.dtx.
%% 
%% This generated file may be distributed as long as the
%% original source files, as listed above, are part of the
%% same distribution. (The sources need not necessarily be
%% in the same archive or directory.)
%% \RCS$Id: brandeis-dissertation.dtx,v 1.9 2004/10/27 00:47:04 turtle Exp $
%% \RCS$Revision: 1.95 $
%% \RCS$Date: 2008/01/14 00:47:04 $
%%
%%  (C) 2000 Andy Garland (aeg@cs.brandeis.edu)
%%  (C) 2001 Pablo Funes (pablo@cs.brandeis.edu)
%%  (C) 2004 Peter Møller Neergaard
%%
%%   This program may be distributed and/or modified under the
%%   conditions of the LaTeX Project Public License, either version 1.2
%%   of this license or (at your option) any later version.
%%   The latest version of this license is in
%%     http://www.latex-project.org/lppl.txt
%%   and version 1.2 or later is part of all distributions of LaTeX
%%   version 1999/12/01 or later.
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{brandeis-dissertation}%
  [2004/10/21 v1.0 Brandeis dissertation settings]
\newif\ifbd@blankclear
\DeclareOption{blankcleared}{\bd@blankcleartrue}
\DeclareOption{numbercleared}{\bd@blankclearfalse}
\newif\ifbd@minmar
\DeclareOption{minmargins}{\bd@minmartrue}
\DeclareOption{15margins}{\bd@minmarfalse}
\newif\ifbd@nochange@small@ftnt
\DeclareOption{12pt}{\def\bd@book@size{12pt}%
  \bd@nochange@small@ftntfalse}
\DeclareOption{11pt}{\def\bd@book@size{11pt}%
  \bd@nochange@small@ftnttrue}
\DeclareOption{10pt}{\def\bd@book@size{10}%
  \bd@nochange@small@ftnttrue}
\DeclareOption{oneside}{\def\bd@book@side{oneside}}
\DeclareOption{twoside}{\def\bd@book@side{twoside}}
\DeclareOption{draft}{\def\bd@book@final{draft}}
\DeclareOption{final}{\def\bd@book@final{final}}
\DeclareOption{openright}{\def\bd@book@openrght{openright}}
\DeclareOption{openany}{\def\bd@book@openrght{openany}}
\DeclareOption{leqno}{\PassOptionsToClass{book}{\currentoption}}
\DeclareOption{fleqno}{\PassOptionsToClass{book}{\currentoption}}
\DeclareOption{openbib}{\PassOptionsToClass{book}{\currentoption}}
\DeclareOption{openbib}{\def\bd@book@openbib{openbib}}
\ExecuteOptions{12pt,openright,final,oneside,%
   minmargins,copyright,nolot,lof}
\ProcessOptions*
\LoadClass[letterpaper,\bd@book@size,\bd@book@side,%
   \bd@book@final,\bd@book@openrght]{book}
\ifbd@nochange@small@ftnt
  \let\small\normalsize
  \let\footnotesize\normalsize
\fi
\let\bd@cleardoublepage@save\cleardoublepage
\newcommand{\bd@cleardoublepageblank}{%
  \clearpage
  \thispagestyle{empty}%
  \bd@cleardoublepage@save}
\ifbd@blankclear
  \AtBeginDocument{\let\cleardoublepage\bd@cleardoublepageblank}
\fi
\RequirePackage[doublespacing]{setspace}
\let\bd@thebibliography\thebibliography
\let\bd@endthebibliography\endthebibliography
\renewenvironment{thebibliography}%
    {\begin{singlespace}\bd@thebibliography}%
  {\bd@endthebibliography\end{singlespace}}
\let\bd@theindex\theindex
\let\bd@endtheindex\endtheindex
\renewenvironment{theindex}{%
    \addcontentsline{toc}{chapter}%
      {\protect\numberline{}\indexname}%
    \bd@theindex\begin{singlespace}\small}%
  {\end{singlespace}\bd@endtheindex}
\let\bd@quotation\quotation
\let\bd@endquotation\endquotation
\renewenvironment{quotation}%
    {\begin{singlespace}\bd@quotation}%
  {\bd@endquotation\end{singlespace}}
\everydisplay\expandafter{%
  \the\everydisplay
  \def\baselinestretch{1.2}\selectfont}
\smallskipamount=2pt plus 1.5pt minus 1.5pt
\smallskipamount=4pt plus 3pt minus 3pt
\bigskipamount=8pt plus 6pt minus 6pt
\RequirePackage[letterpaper]{geometry}
\ifbd@minmar
  \geometry{left=1.5in, top=1in, right=1in, bottom=1in,
    marginparwidth=.5in}
\else
  \geometry{margin=1.5in,marginparwidth=1in}
\fi
\if@twoside
  \def\ps@brandeisheadings{%
      \def\@evenfoot{\hfil\thepage\hfil}%
      \def\@oddfoot{\hfil\thepage\hfil}%
      \def\@evenhead{\hfil{\slhape\leftmark}\hfil}%
      \def\@oddhead{\hfil{\slshape\rightmark}\hfil}%
      \let\@mkboth\markboth
    \def\chaptermark##1{%
      \markboth {\MakeUppercase{%
        \ifnum \c@secnumdepth >\m@ne
          \if@mainmatter
            \@chapapp\ \thechapter. \ %
          \fi
        \fi
        ##1}}{}}%
    \def\sectionmark##1{%
      \markright {\MakeUppercase{%
        \ifnum \c@secnumdepth >\z@
          \thesection. \ %
        \fi
        ##1}}}}
\else
  \def\ps@brandeisheadings{%

          \def\@oddfoot{\hfil\thepage\hfil}%
    \def\@oddhead{\hfil{\slshape\rightmark}\hfil}%
    \let\@mkboth\markboth
    \def\chaptermark##1{%
      \markright {\MakeUppercase{%
        \ifnum \c@secnumdepth >\m@ne
          \if@mainmatter
            \@chapapp\ \thechapter. \ %
          \fi
        \fi
        ##1}}}}
\fi
\let\bd@ps@plain@saved\ps@plain
\let\bd@ps@empty@saved\ps@empty
\let\bd@ps@headings@saved\ps@headings
\let\bd@ps@myheadings@saved\ps@myheadings
\let\bd@ps@brandeisheadings@saved\ps@brandeisheadings
\def\ps@plain{\geometry{includehead=false,includefoot}%
  \bd@ps@plain@saved}
\def\ps@pempty{\geometry{includehead=false,includefoot=false}%
  \bd@ps@empty@saved}
\def\ps@headings{\geometry{includehead,includefoot=false}%
  \bd@ps@headings@saved}
\def\ps@myheadings{\geometry{includehead,includefoot=false}%
  \bd@ps@myheadings@saved}
\def\ps@brandeisheadings{\geometry{includehead,includefoot}%
  \bd@ps@brandeisheadings@saved}
\AtBeginDocument{%
  \let\ps@plain\bd@ps@plain@saved
  \let\ps@empty\bd@ps@empty@saved
  \let\ps@headings\bd@ps@headings@saved
  \let\ps@myheadings\bd@ps@myheadings@saved
  \let\ps@brandeisheadings\bd@ps@brandeisheadings@saved
  \let\bd@ps@plain\@undefined
  \let\bd@ps@empty\@undefined
  \let\bd@ps@headings\@undefined
  \let\bd@ps@myheadings\@undefined
  \let\bd@ps@brandeisheadings\@undefined}
\pagestyle{brandeisheadings}
\newcommand{\thesisfront}[1][]{%
  \@for\bd@option:=#1\do{%
     \@ifundefined{bd@tf@\bd@option}{%
       \@latex@error{\@backslashchar thesisfront: option `\bd@option'
       unknown}%
       {The option you have specified is unknown.  Check the spelling
and \MessageBreak consult the documentation for the\MessageBreak
brandeis-dissertation class.}}%
     {\@nameuse{bd@tf@\bd@option}}}%
  \frontmatter
  \bgroup
  \pagestyle{empty}
  \thesistitlepage\cleardoublepage
  \if@bd@onlinesubmission{\signaturepage}{\signaturepage*}%
  \cleardoublepage
  \if@bd@crpage{\copyrightpage{\@author}{\@graduationyear}%
      \cleardoublepage}%
  \ifx\@dedication\@empty\else
     \dedicationpage{\@dedication}%
     \cleardoublepage
  \fi
  \cleardoublepage
  \egroup
  \bd@optpage*{Acknowledgments}{\@acknowledgments}%
  \cleardoublepage
  \bd@abstract{\@thesisabstract}%
  \cleardoublepage
  \bd@optpage{Preface}{\@preface}%
  \cleardoublepage
  \tableofcontents
  \cleardoublepage
  \if@bd@lot{\listoftables\cleardoublepage}%
  \if@bd@lof{\listoffigures\cleardoublepage}%
  \mainmatter}
\let\if@bd@onlinesubmission\@firstoftwo
\newcommand{\bd@tf@onlinesubmission}{%
  \let\if@bd@onlinesubmission\@firstoftwo}
\newcommand{\bd@tf@papersubmission}{%
  \let\if@bd@onlinesubmission\@secondoftwo}
\let\if@bd@crpage\@iden
\newcommand{\bd@tf@copyrightpage}{\let\if@bd@crpage\@iden}
\newcommand{\bd@tf@nocopyrightpage}{\let\if@bd@crpage\@gobble}
\let\if@bd@lot\@gobble
\newcommand{\bd@tf@lot}{\let\if@bd@lot\@iden}
\newcommand{\bd@tf@nolot}{\let\if@bd@lot\@gobble}
\let\if@bd@lof\@gobble
\newcommand{\bd@tf@lof}{\let\if@bd@lof\@iden}
\newcommand{\bd@tf@nolof}{\let\if@bd@lof\@gobble}
\setcounter{tocdepth}{1}
\let\bd@org@tableofcontents\tableofcontents
\renewcommand{\tableofcontents}{%
  \begin{singlespace}
    \bd@org@tableofcontents
  \end{singlespace}}
\let\bd@org@listoftables\listoftables
\renewcommand{\listoftables}{%
  \begin{singlespace}
    \bd@org@listoftables
 \end{singlespace}}
\let\bd@org@listoffigures\listoffigures
\renewcommand{\listoffigures}{%
  \begin{singlespace}
    \bd@org@listoffigures
  \end{singlespace}}
\renewcommand\mainmatter{%
  \clearpage
  \@mainmattertrue
  \pagenumbering{arabic}}
\gdef\@acknowledgments{}
\gdef\@advisor{}
\gdef\@dean{}
\gdef\@dedication{}
\gdef\@department{}
\gdef\@graduationmonth{May}
\xdef\@graduationyear{\the\year}
\gdef\@othercopyright{}
\gdef\@preface{}
\gdef\@thesisabstract{}
\newcommand{\acknowledgments}[1]{\gdef\@acknowledgments{#1}}
\newcommand{\advisor}[1]{\gdef\@advisor{#1}}
\newcommand{\dean}[1]{\gdef\@dean{#1}}
\newcommand{\dedication}[1]{\gdef\@dedication{#1}}
\newcommand{\department}[1]{\gdef\@department{#1}}
\newcommand{\graduationmonth}[1]{\gdef\@graduationmonth{#1}}
\newcommand{\graduationyear}[1]{\gdef\@graduationyear{#1}}
\newcommand{\othercopyright}[1]{\gdef\@othercopyright{#1}}
\newcommand{\preface}[1]{\gdef\@preface{#1}}
\newcommand{\thesisabstract}[1]{\gdef\@thesisabstract{#1}}
\newcommand{\reader}[1]{%
  \expandafter\gdef
    \expandafter\@committee
       \expandafter{\@committee\do{#1}}}
\gdef\@committee{}
\newcommand{\thesistitlepage}{
  \thispagestyle{empty}%
  \begin{center}
    \vspace*{.25in}%
    {\Huge \bf\baselineskip=.8\baselineskip \@title\\}
    \vspace*{.5in}%
    A Dissertation\\
    \vspace*{.25in}%
    Presented to\\
    The Faculty of the Graduate School of Arts and Sciences\\
    Brandeis University\\
    \@department\\
    \@advisor, Advisor\\
    \vspace*{.5in}
    In Partial Fulfillment\\
    of the Requirements for the Degree\\
    Doctor of Philosophy\\
    \vspace*{.5in}
    by\\
    \@author\\
    \@graduationmonth, \@graduationyear\\
  \end{center}%
  \clearpage}
\newcommand{\copyrightpage}[2]{%
  \thispagestyle{empty}%
  \begin{center}
    \vspace*{2.5in}
     \copyright Copyright by \\
    \vspace*{.05in}
    #1 \\
    \vspace*{.05in}
    #2
  \end{center}
  \vspace{0pt}\vfill%
  \begin{singlespace}
  \begin{raggedright}
    \small
    \@othercopyright
  \end{raggedright}
  \end{singlespace}
  \clearpage}
\newcommand{\dedicationpage}[1]{%
  \thispagestyle{empty}%
  \vspace*{2.5in}%
  \begin{center}%
    #1
  \end{center}%
  \clearpage}
\newenvironment{abstract}{%
  \addcontentsline{toc}{chapter}{Abstract}
  \begin{singlespace}
    \thispagestyle{plain}
    \begin{center}
      {\Huge\bf Abstract\\}%
      \vspace*{.2in}%
      {\large\bf  \@title \\}%
      \vspace*{.1in}%
      \noindent
      A dissertation presented to the Faculty of \\
      the Graduate School of Arts and Sciences of \\
      Brandeis University, Waltham, Massachusetts \\
      \vspace*{0.1in}
      by \@author
    \end{center}
    \end{singlespace}%
    \begin{doublespace}
    \noindent}%
  {\end{doublespace}%
  \clearpage}
\newcommand{\bd@abstract}[1]{%
 \begin{abstract}#1\end{abstract}}
\let\if@bd@sig@lines\@secondoftwo
\newcommand{\signaturepage}{%
  \@ifstar{\let\if@bd@sig@lines\@firstoftwo\bd@sig@page}%
    {\let\if@bd@sig@lines\@secondoftwo\bd@sig@page}}
\newcommand{\bd@sig@page}{%
    \bd@upd@signline@lngth{\@advisor, Chair}
    \let\do\bd@upd@signline@lngth\@committee
    \thispagestyle{empty}%
    \begin{flushleft}%
      \vspace*{.15in}%
      This dissertation, directed and approved by \@author's
      committee, has been accepted and approved by the Graduate
      Faculty of Brandeis University in partial fulfillment of the
      requirements for the degree of:
      \vspace*{0.25in}%
      \begin{flushright}%
        \centerline{\bfseries DOCTOR OF PHILOSOPHY}%
        \par
        \parbox{3.6in}{%
          \vspace{.8in}%
          \if@bd@sig@lines{\bd@signline{2.9in}}{}%
          \@dean, Dean of Arts and Sciences}%
      \end{flushright}%
      \vspace*{0.4in}%
      Dissertation Committee:
      \par
      \bd@sig@page@item{\@advisor, Chair}%
      {\let\do\bd@sig@page@item\@committee}%
    \end{flushleft}
    \clearpage}
\newcommand{\bd@sig@page@item}[1]{%
  \if@bd@sig@lines{%
     \penalty10000\vskip.6in minus 1in%
     \bd@signline{\bd@comm@signline@lngth}}%
   {\par}%
  #1}
\newcommand{\bd@signline}[1]{%
  \rule[.5\baselineskip]{#1}{0.4pt}\hskip-#1\relax\ignorespaces}
\newlength{\bd@comm@signline@lngth}
\setlength{\bd@comm@signline@lngth}{2.5in}
\newcommand{\bd@upd@signline@lngth}[1]{%
  {\setbox0=\hbox{#1}%
  \ifdim \wd0>\bd@comm@signline@lngth
    \global\bd@comm@signline@lngth=\wd0
  \fi}}
\newenvironment{optionalpage}[1]{%
  \chapter{#1}}%
  {\clearpage}
\newenvironment{optionalpage*}[1]{%
  \chapter*{#1}}%
  {\clearpage}
\newcommand{\bd@optpage}{%
  \@ifstar{\bd@optpage@i{optionalpage*}}{\bd@optpage@i{optionalpage}}}
\newcommand{\bd@optpage@i}[3]{%
  \ifx\@empty#3
     \expandafter\@gobble
  \else
     \expandafter\@iden
  \fi
  {\begin{#1}{#2}#3\end{#1}}}

\endinput
%%
%% End of file `brandeis-dissertation.cls'.
