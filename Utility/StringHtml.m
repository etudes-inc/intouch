/**********************************************************************************
 * $URL: https://source.etudes.org/svn/intouch/intouch-ios/trunk/Utility/StringHtml.m $
 * $Id: StringHtml.m 2642 2012-02-11 22:22:13Z ggolden $
 ***********************************************************************************
 *
 * Copyright (c) 2011, 2012 Etudes, Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **********************************************************************************/

#import "StringHtml.h"

static NSString* htmlEntities[] =
{
	// Note: nbsp is first so we can skip in in stringHtmlFromPlain; amp is left out, treated specially
	@"&nbsp;", @"&#160;", @" ",
	@"&lt;", @"&#60;", @"<",
	@"&gt;", @"&#62;", @">",
	@"&cent;", @"&#162;", @"\u00A2", // cent
	@"&pound;", @"&#163;", @"\u00A3", // pound
	@"&yen;", @"&#165;", @"\u00A5", // yen
	@"&euro;", @"&#8364;", @"\u20AC", // euro
	@"&sect;", @"&#167;", @"\u00A7", // section
	@"&copy;", @"&#169;", @"\u00A9", // copyright
	@"&reg;", @"&#174;", @"\u00AE", // registered trademark
	@"&trade;", @"&#8482;", @"\u2122", // trademark
	@"&bull;", @"&#8226;", @"\u2022", // bullet
	@"&quot;", @"&#34;", @"\"", // "\u0022", quote
	
	@"&apos;", @"&#39;", @"'", // APOSTROPHE
	@"&iexcl;", @"&#161;", @"\u00A1", // INVERTED EXCLAMATION MARK
	@"&curren;", @"&#164;", @"\u00A4", // CURRENCY SIGN
	@"&brvbar;", @"&#166;", @"\u00A6", // BROKEN BAR
	@"&uml;", @"&#168;", @"\u00A8", // DIAERESIS
	@"&ordf;", @"&#170;", @"\u00AA", // FEMININE ORDINAL INDICATOR
	@"&laquo;", @"&#171;", @"\u00AB", // LEFT-POINTING DOUBLE ANGLE QUOTATION MARK
	@"&not;", @"&#172;", @"\u00AC", // NOT SIGN
	@"&shy;", @"&#173;", @"\u00AD", // SOFT HYPHEN
	@"&macr;", @"&#175;", @"\u00AF", // MACRON
	@"&deg;", @"&#176;", @"\u00B0", // DEGREE SIGN
	@"&plusmn;", @"&#177;", @"\u00B1", // PLUS-MINUS SIGN
	@"&sup2;", @"&#178;", @"\u00B2", // SUPERSCRIPT TWO
	@"&sup3;", @"&#179;", @"\u00B3", // SUPERSCRIPT THREE
	@"&acute;", @"&#180;", @"\u00B4", // ACUTE ACCENT
	@"&micro;", @"&#181;", @"\u00B5", // MICRO SIGN
	@"&para;", @"&#182;", @"\u00B6", // PILCROW SIGN
	@"&middot;", @"&#183;", @"\u00B7", // MIDDLE DOT
	@"&cedil;", @"&#184;", @"\u00B8", // CEDILLA
	@"&sup1;", @"&#185;", @"\u00B9", // SUPERSCRIPT ONE
	@"&ordm;", @"&#186;", @"\u00BA", // MASCULINE ORDINAL INDICATOR
	@"&raquo;", @"&#187;", @"\u00BB", // RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK
	@"&frac14;", @"&#188;", @"\u00BC", // VULGAR FRACTION ONE QUARTER
	@"&frac12;", @"&#189;", @"\u00BD", // VULGAR FRACTION ONE HALF
	@"&frac34;", @"&#190;", @"\u00BE", // VULGAR FRACTION THREE QUARTERS
	@"&iquest;", @"&#191;", @"\u00BF", // INVERTED QUESTION MARK
	@"&times;", @"&#215;", @"\u00D7", // MULTIPLICATION SIGN
	@"&divide;", @"&#247;", @"\u00F7", // DIVISION SIGN
	
	@"&Agrave;", @"&#192;", @"\u00C0", // "capital a, grave accent"
	@"&Aacute;", @"&#193;", @"\u00C1", // "capital a, acute accent"
	@"&Acirc;", @"&#194;", @"\u00C2", // "capital a, circumflex accent"
	@"&Atilde;", @"&#195;", @"\u00C3", // "capital a, tilde"
	@"&Auml;", @"&#196;", @"\u00C4", // "capital a, umlaut mark"
	@"&Aring;", @"&#197;", @"\u00C5", // "capital a, ring"
	@"&AElig;", @"&#198;", @"\u00C6", // capital ae
	@"&Ccedil;", @"&#199;", @"\u00C7", // "capital c, cedilla"
	@"&Egrave;", @"&#200;", @"\u00C8", // "capital e, grave accent"
	@"&Eacute;", @"&#201;", @"\u00C9", // "capital e, acute accent"
	@"&Ecirc;", @"&#202;", @"\u00CA", // "capital e, circumflex accent"
	@"&Euml;", @"&#203;", @"\u00CB", // ""capital e, umlaut mark"
	@"&Igrave;", @"&#204;", @"\u00CC", // ""capital i, grave accent"
	@"&Iacute;", @"&#205;", @"\u00CD", // ""capital i, acute accent"
	@"&Icirc;", @"&#206;", @"\u00CE", // ""capital i, circumflex accent"
	@"&Iuml;", @"&#207;", @"\u00CF", // ""capital i, umlaut mark"
	@"&ETH;", @"&#208;", @"\u00D0", // ""capital eth, Icelandic"
	@"&Ntilde;", @"&#209;", @"\u00D1", // ""capital n, tilde"
	@"&Ograve;", @"&#210;", @"\u00D2", // ""capital o, grave accent"
	@"&Oacute;", @"&#211;", @"\u00D3", // ""capital o, acute accent"
	@"&Ocirc;", @"&#212;", @"\u00D4", // ""capital o, circumflex accent"
	@"&Otilde;", @"&#213;", @"\u00D5", // ""capital o, tilde"
	@"&Ouml;", @"&#214;", @"\u00D6", // "capital o, umlaut mark"
	@"&Oslash;", @"&#216;", @"\u00D8", // "capital o, slash"
	@"&Ugrave;", @"&#217;", @"\u00D9", // "capital u, grave accent"
	@"&Uacute;", @"&#218;", @"\u00DA", // "capital u, acute accent"
	@"&Ucirc;", @"&#219;", @"\u00DB", // "capital u, circumflex accent"
	@"&Uuml;", @"&#220;", @"\u00DC", // "capital u, umlaut mark"
	@"&Yacute;", @"&#221;", @"\u00DD", // "capital y, acute accent"
	@"&THORN;", @"&#222;", @"\u00DE", // "capital THORN, Icelandic"
	@"&szlig;", @"&#223;", @"\u00DF", // "small sharp s, German"
	@"&agrave;", @"&#224;", @"\u00E0", // "small a, grave accent"
	@"&aacute;", @"&#225;", @"\u00E1", // "small a, acute accent"
	@"&acirc;", @"&#226;", @"\u00E2", // "small a, circumflex accent"
	@"&atilde;", @"&#227;", @"\u00E3", // "small a, tilde"
	@"&auml;", @"&#228;", @"\u00E4", // "small a, umlaut mark"
	@"&aring;", @"&#229;", @"\u00E5", // "small a, ring"
	@"&aelig;", @"&#230;", @"\u00E6", // small ae
	@"&ccedil;", @"&#231;", @"\u00E7", // "small c, cedilla"
	@"&egrave;", @"&#232;", @"\u00E8", // "small e, grave accent"
	@"&eacute;", @"&#233;", @"\u00E9", // "small e, acute accent"
	@"&ecirc;", @"&#234;", @"\u00EA", // "small e, circumflex accent"
	@"&euml;", @"&#235;", @"\u00EB", // "small e, umlaut mark"
	@"&igrave;", @"&#236;", @"\u00EC", // "small i, grave accent"
	@"&iacute;", @"&#237;", @"\u00ED", // "small i, acute accent"
	@"&icirc;", @"&#238;", @"\u00EE", // "small i, circumflex accent"
	@"&iuml;", @"&#239;", @"\u00EF", // "small i, umlaut mark"
	@"&eth;", @"&#240;", @"\u00F0", // "small eth, Icelandic"
	@"&ntilde;", @"&#241;", @"\u00F1", // "small n, tilde"
	@"&ograve;", @"&#242;", @"\u00F2", // "small o, grave accent"
	@"&oacute;", @"&#243;", @"\u00F3", // "small o, acute accent"
	@"&ocirc;", @"&#244;", @"\u00F4", // "small o, circumflex accent"
	@"&otilde;", @"&#245;", @"\u00F5", // "small o, tilde"
	@"&ouml;", @"&#246;", @"\u00F6", // "small o, umlaut mark"
	@"&oslash;", @"&#248;", @"\u00F8", // "small o, slash"
	@"&ugrave;", @"&#249;", @"\u00F9", // "small u, grave accent"
	@"&uacute;", @"&#250;", @"\u00FA", // "small u, acute accent"
	@"&ucirc;", @"&#251;", @"\u00FB", // "small u, circumflex accent"
	@"&uuml;", @"&#252;", @"\u00FC", // "small u, umlaut mark"
	@"&yacute;", @"&#253;", @"\u00FD", // "small y, acute accent"
	@"&thorn;", @"&#254;", @"\u00FE", // "small thorn, Icelandic"
	@"&yuml;", @"&#255;", @"\u00FF", // "small y, umlaut mark"
	
	@"&forall;", @"&#8704;", @"\u2200", // for all
	@"&part;", @"&#8706;", @"\u2202", // part
	@"&exist;", @"&#8707;", @"\u2203", // exists
	@"&empty;", @"&#8709;", @"\u2205", // empty
	@"&nabla;", @"&#8711;", @"\u2207", // nabla
	@"&isin;", @"&#8712;", @"\u2208", // isin
	@"&notin;", @"&#8713;", @"\u2209", // notin
	@"&ni;", @"&#8715;", @"\u220B", // ni
	@"&prod;", @"&#8719;", @"\u220F", // prod
	@"&sum;", @"&#8721;", @"\u2211", // sum
	@"&minus;", @"&#8722;", @"\u2212", // minus
	@"&lowast;", @"&#8727;", @"\u2217", // lowast
	@"&radic;", @"&#8730;", @"\u221A", // square root
	@"&prop;", @"&#8733;", @"\u221D", // proportional to
	@"&infin;", @"&#8734;", @"\u221E", // infinity
	@"&ang;", @"&#8736;", @"\u2220", // angle
	@"&and;", @"&#8743;", @"\u2227", // and
	@"&or;", @"&#8744;", @"\u2228", // or
	@"&cap;", @"&#8745;", @"\u2229", // cap
	@"&cup;", @"&#8746;", @"\u222A", // cup
	@"&int;", @"&#8747;", @"\u222B", // integral
	@"&there4;", @"&#8756;", @"\u2234", // therefore
	@"&sim;", @"&#8764;", @"\u223C", // similar to
	@"&cong;", @"&#8773;", @"\u2245", // congruent to
	@"&asymp;", @"&#8776;", @"\u2248", // almost equal
	@"&ne;", @"&#8800;", @"\u2260", // not equal
	@"&equiv;", @"&#8801;", @"\u2261", // equivalent
	@"&le;", @"&#8804;", @"\u2264", // less or equal
	@"&ge;", @"&#8805;", @"\u2265", // greater or equal
	@"&sub;", @"&#8834;", @"\u2282", // subset of
	@"&sup;", @"&#8835;", @"\u2283", // superset of
	@"&nsub;", @"&#8836;", @"\u2284", // not subset of
	@"&sube;", @"&#8838;", @"\u2286", // subset or equal
	@"&supe;", @"&#8839;", @"\u2287", // superset or equal
	@"&oplus;", @"&#8853;", @"\u2295", // circled plus
	@"&otimes;", @"&#8855;", @"\u2297", // circled times
	@"&perp;", @"&#8869;", @"\u22A5", // perpendicular
	@"&sdot;", @"&#8901;", @"\u22C5", // dot operator
	
	@"&Alpha;", @"&#913;", @"\u0391", // Alpha
	@"&Beta;", @"&#914;", @"\u0392", // Beta
	@"&Gamma;", @"&#915;", @"\u0393", // Gamma
	@"&Delta;", @"&#916;", @"\u0394", // Delta
	@"&Epsilon;", @"&#917;", @"\u0395", // Epsilon
	@"&Zeta;", @"&#918;", @"\u0396", // Zeta
	@"&Eta;", @"&#919;", @"\u0397", // Eta
	@"&Theta;", @"&#920;", @"\u0398", // Theta
	@"&Iota;", @"&#921;", @"\u0399", // Iota
	@"&Kappa;", @"&#922;", @"\u039A", // Kappa
	@"&Lambda;", @"&#923;", @"\u039B", // Lambda
	@"&Mu;", @"&#924;", @"\u039C", // Mu
	@"&Nu;", @"&#925;", @"\u039D", // Nu
	@"&Xi;", @"&#926;", @"\u039E", // Xi
	@"&Omicron;", @"&#927;", @"\u039F", // Omicron
	@"&Pi;", @"&#928;", @"\u03A0", // Pi
	@"&Rho;", @"&#929;", @"\u03A1", // Rho
	@"&Sigma;", @"&#931;", @"\u03A3", // Sigma
	@"&Tau;", @"&#932;", @"\u03A4", // Tau
	@"&Upsilon;", @"&#933;", @"\u03A5", // Upsilon
	@"&Phi;", @"&#934;", @"\u03A6", // Phi
	@"&Chi;", @"&#935;", @"\u03A7", // Chi
	@"&Psi;", @"&#936;", @"\u03A8", // Psi
	@"&Omega;", @"&#937;", @"\u03A9", // Omega
	@"&alpha;", @"&#945;", @"\u03B1", // alpha
	@"&beta;", @"&#946;", @"\u03B2", // beta
	@"&gamma;", @"&#947;", @"\u03B3", // gamma
	@"&delta;", @"&#948;", @"\u03B4", // delta
	@"&epsilon;", @"&#949;", @"\u03B5", // epsilon
	@"&zeta;", @"&#950;", @"\u03B6", // zeta
	@"&eta;", @"&#951;", @"\u03B7", // eta
	@"&theta;", @"&#952;", @"\u03B8", // theta
	@"&iota;", @"&#953;", @"\u03B9", // iota
	@"&kappa;", @"&#954;", @"\u03BA", // kappa
	@"&lambda;", @"&#955;", @"\u03BB", // lambda
	@"&mu;", @"&#956;", @"\u03BC", // mu
	@"&nu;", @"&#957;", @"\u03BD", // nu
	@"&xi;", @"&#958;", @"\u03BE", // xi
	@"&omicron;", @"&#959;", @"\u03BF", // omicron
	@"&pi;", @"&#960;", @"\u03C0", // pi
	@"&rho;", @"&#961;", @"\u03C1", // rho
	@"&sigmaf;", @"&#962;", @"\u03C2", // sigmaf
	@"&sigma;", @"&#963;", @"\u03C3", // sigma
	@"&tau;", @"&#964;", @"\u03C4", // tau
	@"&upsilon;", @"&#965;", @"\u03C5", // upsilon
	@"&phi;", @"&#966;", @"\u03C6", // phi
	@"&chi;", @"&#967;", @"\u03C7", // chi
	@"&psi;", @"&#968;", @"\u03C8", // psi
	@"&omega;", @"&#969;", @"\u03C9", // omega
	@"&thetasym;", @"&#977;", @"\u03D1", // theta symbol
	@"&upsih;", @"&#978;", @"\u03D2", // upsilon symbol
	@"&piv;", @"&#982;", @"\u03D6", // pi symbol
	
	@"&OElig;", @"&#338;", @"\u0152", // capital ligature OE
	@"&oelig;", @"&#339;", @"\u0153", // small ligature oe
	@"&Scaron;", @"&#352;", @"\u0160", // capital S with caron
	@"&scaron;", @"&#353;", @"\u0161", // small S with caron
	@"&Yuml;", @"&#376;", @"\u0178", // capital Y with diaeres
	@"&fnof;", @"&#402;", @"\u0192", // f with hook
	@"&circ;", @"&#710;", @"\u02C6", // modifier letter circumflex accent
	@"&tilde;", @"&#732;", @"\u02DC", // small tilde
	@"&ensp;", @"&#8194;", @"\u2002", // en space
	@"&emsp;", @"&#8195;", @"\u2003", // em space
	@"&thinsp;", @"&#8201;", @"\u2009", // thin space
	@"&zwnj;", @"&#8204;", @"\u200C", // zero width non-joiner
	@"&zwj;", @"&#8205;", @"\u200D", // zero width joiner
	@"&lrm;", @"&#8206;", @"\u200E", // left-to-right mark
	@"&rlm;", @"&#8207;", @"\u200F", // right-to-left mark
	@"&ndash;", @"&#8211;", @"\u2013", // en dash
	@"&mdash;", @"&#8212;", @"\u2014", // em dash
	@"&lsquo;", @"&#8216;", @"\u2018", // left single quotation mark
	@"&rsquo;", @"&#8217;", @"\u2019", // right single quotation mark
	@"&sbquo;", @"&#8218;", @"\u201A", // single low-9 quotation mark
	@"&ldquo;", @"&#8220;", @"\u201C", // left double quotation mark
	@"&rdquo;", @"&#8221;", @"\u201D", // right double quotation mark
	@"&bdquo;", @"&#8222;", @"\u201E", // double low-9 quotation mark
	@"&dagger;", @"&#8224;", @"\u2020", // dagger
	@"&Dagger;", @"&#8225;", @"\u2021", // double dagger
	@"&hellip;", @"&#8230;", @"\u2026", // horizontal ellipsis
	@"&permil;", @"&#8240;", @"\u2030", // per mille
	@"&prime;", @"&#8242;", @"\u2032", // minutes
	@"&Prime;", @"&#8243;", @"\u2033", // seconds
	@"&lsaquo;", @"&#8249;", @"\u2039", // single left angle quotation
	@"&rsaquo;", @"&#8250;", @"\u203A", // single right angle quotation
	@"&oline;", @"&#8254;", @"\u203E", // overline
	@"&larr;", @"&#8592;", @"\u2190", // left arrow
	@"&uarr;", @"&#8593;", @"\u2191", // up arrow
	@"&rarr;", @"&#8594;", @"\u2192", // right arrow
	@"&darr;", @"&#8595;", @"\u2193", // down arrow
	@"&harr;", @"&#8596;", @"\u2194", // left right arrow
	@"&crarr;", @"&#8629;", @"\u2185", // carriage return arrow
	@"&lceil;", @"&#8968;", @"\u2308", // left ceiling
	@"&rceil;", @"&#8969;", @"\u2309", // right ceiling
	@"&lfloor;", @"&#8970;", @"\u230A", // left floor
	@"&rfloor;", @"&#8971;", @"\u230B", // right floor
	@"&loz;", @"&#9674;", @"\u25CA", // lozenge
	@"&spades;", @"&#9824;", @"\u2660", // spade
	@"&clubs;", @"&#9827;", @"\u2663", // club
	@"&hearts;", @"&#9829;", @"\u2665", // heart
	@"&diams;", @"&#9830;", @"\u2666", // diamond

	nil
};

@implementation NSString (StringHtml)

- (NSString *) trimToNil
{
	NSString *rv = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([rv length] == 0) rv = nil;
	return rv;
}

- (BOOL) boldToHtml:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"\\[b\\](.*?)\\[/b\\]"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"<strong>$1</strong>"];
	
	return (count > 0);
}

- (BOOL) boldToPlain:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<strong>(.*?)</strong>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"[b]$1[/b]"];
	
	NSRegularExpression *regex2 = [NSRegularExpression
								   regularExpressionWithPattern:@"<b>(.*?)</b>"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	count += [regex2 replaceMatchesInString:buf
									options:0
									  range:NSMakeRange(0, [buf length])
							   withTemplate:@"[b]$1[/b]"];
	
	return (count > 0);
}

- (BOOL) centerToHtml:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								   regularExpressionWithPattern:@"\\[center\\](.*?)\\[/center\\]"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											  options:0
												range:NSMakeRange(0, [buf length])
										 withTemplate:@"<div align=\"center\">$1</div>"];
	
	return (count > 0);
}

- (BOOL) centerToPlain:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<div align\\s*=\\s*\"center\">(.*?)</div>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"[center]$1[/center]"];
	
	NSRegularExpression *regex2 = [NSRegularExpression
								   regularExpressionWithPattern:@"<p align\\s*=\\s*\"center\">(.*?)</p>"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	count += [regex2 replaceMatchesInString:buf
									options:0
									  range:NSMakeRange(0, [buf length])
							   withTemplate:@"[center]$1[/center]"];
	
	return (count > 0);
}

- (BOOL) divToPlain:(NSMutableString *)buf
{
	// match <div> tags, collect the text within the tag, add a new line before and after
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<div.*?>(.*?)</div>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"\n$1\n"];
	return (count > 0);
}

- (BOOL) dtToPlain:(NSMutableString *)buf
{
	// match <dt> tags, collect the text within the tag, add a dash, and new line before
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<dt.*?>(.*?)</dt>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"\n- $1"];
	return (count > 0);
}

- (BOOL) emotToHtml:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"\\[emot\\](.*?)\\[/emot\\]"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"<img src=\"/library/editor/FCKeditor/editor/images/smiley/msn/$1.gif\" alt=\"emoticon $1\" />"];
	return (count > 0);
}

- (BOOL) emotToPlain:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<img.*?src\\s*=\\s*\"/library/editor/FCKeditor/editor/images/smiley/msn/(.*?).gif\".*?/>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"[emot]$1[/emot]"];
	return (count > 0);
}

- (BOOL) fontToHtml:(NSMutableString *)buf
{
	NSError *error = NULL;

	NSRegularExpression *regex1 = [NSRegularExpression
								   regularExpressionWithPattern:@"\\[size\\s*=\\s*(.*?)\\](.*?)\\[/size\\]"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];

	NSUInteger count = [regex1 replaceMatchesInString:buf
											  options:0
												range:NSMakeRange(0, [buf length])
										 withTemplate:@"<font size=\"$1\">$2</font>"];
	
	NSRegularExpression *regex2 = [NSRegularExpression
								   regularExpressionWithPattern:@"\\[color\\s*=\\s*(.*?)\\](.*?)\\[/color\\]"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	count += [regex2 replaceMatchesInString:buf
									options:0
									  range:NSMakeRange(0, [buf length])
							   withTemplate:@"<font color=\"$1\">$2</font>"];
	
	// collapse double fonts
	NSRegularExpression *regex3 = [NSRegularExpression
								   regularExpressionWithPattern:@"<font(.*?)><font(.*?)>(.*?)</font></font>"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	[regex3 replaceMatchesInString:buf
						   options:0
							 range:NSMakeRange(0, [buf length])
					  withTemplate:@"<font$1$2>$3</font>"];
	
	return (count > 0);
}

- (BOOL) fontToPlain:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<font(.*?)>(.*?)</font>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSRegularExpression *regexSize = [NSRegularExpression
									   regularExpressionWithPattern:@"size\\s*=\\s*\"(.*?)\""
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	NSRegularExpression *regexColor = [NSRegularExpression
										regularExpressionWithPattern:@"color\\s*=\\s*\"(.*?)\""
										options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
										error:&error];
	
	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange attrsRange = [match rangeAtIndex:1];
			 NSString *attrsString = [buf substringWithRange:attrsRange];
			 NSRange bodyRange = [match rangeAtIndex:2];
			 NSString *bodyStr = [buf substringWithRange:bodyRange];
			 
			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // find optional size and color from the matching string
			 NSString *size = nil;
			 NSString *color = nil;
			 NSTextCheckingResult *m2 = [regexSize firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) size = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexColor firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) color = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];

			 if (color != nil)
			 {
				 [converted appendFormat:@"[color=%@]", color];
			 }
			 if (size != nil)
			 {
				 [converted appendFormat:@"[size=%@]", size];
			 }
			 [converted appendString:bodyStr];
			 if (size != nil)
			 {
				 [converted appendString:@"[/size]"];
			 }
			 if (color != nil)
			 {
				 [converted appendString:@"[/color]"];
			 }			 
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) imageToHtml:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"\\[img(.*?)\\](.*?)\\[/img\\]"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSRegularExpression *regexWidth = [NSRegularExpression
									   regularExpressionWithPattern:@"width\\s*=\\s*&quot;(.*?)&quot;"
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	NSRegularExpression *regexHeight = [NSRegularExpression
										regularExpressionWithPattern:@"height\\s*=\\s*&quot;(.*?)&quot;"
										options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
										error:&error];
	
	
	NSRegularExpression *regexAlt = [NSRegularExpression
									 regularExpressionWithPattern:@"alt\\s*=\\s*&quot;(.*?)&quot;"
									 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									 error:&error];
	
	
	NSRegularExpression *regexTitle = [NSRegularExpression
									   regularExpressionWithPattern:@"title\\s*=\\s*&quot;(.*?)&quot;"
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange attrsRange = [match rangeAtIndex:1];
			 NSString *attrsStr = [buf substringWithRange:attrsRange];
			 NSRange srcRange = [match rangeAtIndex:2];
			 NSString *srcStr = [buf substringWithRange:srcRange];
			 
			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // find optional width and height, alt and title from the matching string
			 NSString *width = nil;
			 NSString *height = nil;
			 NSString *alt = nil;
			 NSString *title = nil;
			 NSTextCheckingResult *m2 = [regexWidth firstMatchInString:attrsStr options:0 range:NSMakeRange(0, [attrsStr length])];
			 if (m2 != nil) width = [[attrsStr substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexHeight firstMatchInString:attrsStr options:0 range:NSMakeRange(0, [attrsStr length])];
			 if (m2 != nil) height = [[attrsStr substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexAlt firstMatchInString:attrsStr options:0 range:NSMakeRange(0, [attrsStr length])];
			 if (m2 != nil) alt = [[attrsStr substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexTitle firstMatchInString:attrsStr options:0 range:NSMakeRange(0, [attrsStr length])];
			 if (m2 != nil) title = [[attrsStr substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 
			 [converted appendString:@"<img"];
			 if (width != nil) [converted appendFormat:@" width=\"%@\"", width];
			 if (height != nil) [converted appendFormat:@" height=\"%@\"", height];
			 if (alt != nil) [converted appendFormat:@" alt=\"%@\"", alt];
			 if (title != nil) [converted appendFormat:@" title=\"%@\"", title];
			 [converted appendFormat:@" src=\"%@\" />", srcStr];
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) imageToPlain:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<img(.*?)/>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSRegularExpression *regexWidth = [NSRegularExpression
									   regularExpressionWithPattern:@"width\\s*=\\s*\"(.*?)\""
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	NSRegularExpression *regexHeight = [NSRegularExpression
										regularExpressionWithPattern:@"height\\s*=\\s*\"(.*?)\""
										options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
										error:&error];
	
	NSRegularExpression *regexSrc = [NSRegularExpression
									 regularExpressionWithPattern:@"src\\s*=\\s*\"(.*?)\""
									 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									 error:&error];
	
	NSRegularExpression *regexAlt = [NSRegularExpression
									 regularExpressionWithPattern:@"alt\\s*=\\s*\"(.*?)\""
									 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									 error:&error];
	
	NSRegularExpression *regexTitle = [NSRegularExpression
									   regularExpressionWithPattern:@"title\\s*=\\s*\"(.*?)\""
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange attrsRange = [match rangeAtIndex:1];
			 NSString *attrsString = [buf substringWithRange:attrsRange];
			 
			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // find optional width and height, and the src, from the attributes
			 NSString *width = nil;
			 NSString *height = nil;
			 NSString *src = nil;
			 NSString *alt = nil;
			 NSString *title = nil;
			 NSTextCheckingResult *m2 = [regexWidth firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) width = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexHeight firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) height = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexSrc firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) src = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexAlt firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) alt = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexTitle firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) title = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 
			 // convert /cdp/doc/access -> /access
			 if ([src hasPrefix:@"/cdp/doc/access/"])
			 {
				 src = [src substringFromIndex:8];
			 }

			 [converted appendString:@"[img"];
			 if (width != nil) [converted appendFormat:@" width=\"%@\"", width];
			 if (height != nil) [converted appendFormat:@" height=\"%@\"", height];
			 if (alt != nil) [converted appendFormat:@" alt=\"%@\"", alt];
			 if (title != nil) [converted appendFormat:@" title=\"%@\"", title];
			 [converted appendFormat:@"]%@[/img]", src];
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) italicToHtml:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex1 = [NSRegularExpression
								   regularExpressionWithPattern:@"\\[i\\](.*?)\\[/i\\]"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	NSUInteger count = [regex1 replaceMatchesInString:buf
											  options:0
												range:NSMakeRange(0, [buf length])
										 withTemplate:@"<em>$1</em>"];
	
	return (count > 0);
}

- (BOOL) italicToPlain:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<em>(.*?)</em>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"[i]$1[/i]"];
	
	NSRegularExpression *regex2 = [NSRegularExpression
								   regularExpressionWithPattern:@"<i>(.*?)</i>"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	count += [regex2 replaceMatchesInString:buf
									options:0
									  range:NSMakeRange(0, [buf length])
							   withTemplate:@"[i]$1[/i]"];
	
	return (count > 0);
}

- (BOOL) linkToHtml1:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"\\[url\\s*=\\s*(.*?)](.*?)\\[/url\\]"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];

	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange urlRange = [match rangeAtIndex:1];
			 NSString *urlStr = [buf substringWithRange:urlRange];
			 NSRange textRange = [match rangeAtIndex:2];
			 NSString *textStr = [buf substringWithRange:textRange];
			 
			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // fix the URL
			 BOOL isRelative = [urlStr hasPrefix:@"/"];
			 BOOL hasTransport = ([urlStr rangeOfString:@"://"].location != NSNotFound);
			 if (!isRelative && !hasTransport) urlStr = [NSString stringWithFormat:@"http://%@", urlStr];

			 [converted appendFormat:@"<a target=\"_blank\" href=\"%@\">%@</a>", urlStr, textStr];
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) linkToHtml2:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"\\[url](.*?)\\[/url\\]"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange urlRange = [match rangeAtIndex:1];
			 NSString *urlStr = [buf substringWithRange:urlRange];
			 NSString *textStr = [buf substringWithRange:urlRange];
			 
			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // fix the URL
			 BOOL isRelative = [urlStr hasPrefix:@"/"];
			 BOOL hasTransport = ([urlStr rangeOfString:@"://"].location != NSNotFound);
			 if (!isRelative && !hasTransport) urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
			 
			 [converted appendFormat:@"<a target=\"_blank\" href=\"%@\">%@</a>", urlStr, textStr];
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) linkToHtml:(NSMutableString *)buf
{
	int count1 = [self linkToHtml1:buf];
	int count2 = [self linkToHtml2:buf];
	return ((count1 + count2) > 0);

/*
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"\\[url\\s*=\\s*(.*?)](.*?)\\[/url\\]"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"<a target=\"_blank\" href=\"$1\">$2</a>"];
	
	// and the [url] format
	NSRegularExpression *regex2 = [NSRegularExpression
								   regularExpressionWithPattern:@"\\[url](.*?)\\[/url\\]"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	count += [regex2 replaceMatchesInString:buf
									options:0
									  range:NSMakeRange(0, [buf length])
							   withTemplate:@"<a target=\"_blank\" href=\"$1\">$1</a>"];
	
	return (count > 0);
*/
}

- (BOOL) linkToPlain:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<a.*?href\\s*=\\s*\"(.*?)\".*?>(.*?)</a>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"[url=$1]$2[/url]"];
	return (count > 0);
}

- (BOOL) listToPlain:(NSMutableString *)buf
{
	// match <ul> and <ol> and <dl> tags, collect the text within the tag, and surround with /n like a div
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<(ul|ol|dl).*?>(.*?)</\\1>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"\n$2\n"];
	return (count > 0);
}

- (BOOL) liToPlain:(NSMutableString *)buf
{
	// match <li> tags, collect the text within the tag, add a dash, and new line before
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<li.*?>(.*?)</li>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"\n- $1"];
	return (count > 0);
}

- (BOOL) pToPlain:(NSMutableString *)buf
{
	// match <p> and </o> tags, replace with a new line
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<p.*?>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger count = [regex replaceMatchesInString:buf
											 options:0
											   range:NSMakeRange(0, [buf length])
										withTemplate:@"\n"];
	
	NSRegularExpression *regex2 = [NSRegularExpression
								   regularExpressionWithPattern:@"</p>"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	count += [regex2 replaceMatchesInString:buf
									options:0
									  range:NSMakeRange(0, [buf length])
							   withTemplate:@"\n"];
	return (count > 0);
}

- (BOOL) strikeToHtml:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex1 = [NSRegularExpression
								   regularExpressionWithPattern:@"\\[s\\](.*?)\\[/s\\]"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	NSUInteger count = [regex1 replaceMatchesInString:buf
											  options:0
												range:NSMakeRange(0, [buf length])
										 withTemplate:@"<strike>$1</strike>"];
	
	return (count > 0);
}

- (BOOL) strikeToPlain:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex1 = [NSRegularExpression
								   regularExpressionWithPattern:@"<strike>(.*?)</strike>"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	NSUInteger count = [regex1 replaceMatchesInString:buf
											  options:0
												range:NSMakeRange(0, [buf length])
										 withTemplate:@"[s]$1[/s]"];
	
	return (count > 0);
}

- (BOOL) tagsToPlain:(NSMutableString *)buf
{
	// drop any tags
	NSError *error = nil;
	NSRegularExpression *regex1 = [NSRegularExpression
								  regularExpressionWithPattern:@"<.*?>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];

	NSUInteger count = [regex1 replaceMatchesInString:buf
											  options:0
												range:NSMakeRange(0, [buf length])
										 withTemplate:@""];
	
	return (count > 0);
}

- (BOOL) underlineToHtml:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex1 = [NSRegularExpression
								   regularExpressionWithPattern:@"\\[u\\](.*?)\\[/u\\]"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	NSUInteger count = [regex1 replaceMatchesInString:buf
											  options:0
												range:NSMakeRange(0, [buf length])
										 withTemplate:@"<u>$1</u>"];
	
	return (count > 0);
}

- (BOOL) underlineToPlain:(NSMutableString *)buf
{
	NSError *error = NULL;
	NSRegularExpression *regex1 = [NSRegularExpression
								   regularExpressionWithPattern:@"<u>(.*?)</u>"
								   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								   error:&error];
	
	NSUInteger count = [regex1 replaceMatchesInString:buf
											  options:0
												range:NSMakeRange(0, [buf length])
										 withTemplate:@"[u]$1[/u]"];
	
	return (count > 0);
}

- (BOOL) youtubeAToPlain:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<iframe(.*?www.youtube.com/embed/(.*?)[\"\\?].*?)>.*?</iframe>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSRegularExpression *regexWidth = [NSRegularExpression
									   regularExpressionWithPattern:@"width\\s*=\\s*\"(.*?)\""
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	NSRegularExpression *regexHeight = [NSRegularExpression
										regularExpressionWithPattern:@"height\\s*=\\s*\"(.*?)\""
										options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
										error:&error];	
	
	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange attrsRange = [match rangeAtIndex:1];
			 NSRange srcRange = [match rangeAtIndex:2];
			 NSString *attrsString = [buf substringWithRange:attrsRange];
			 NSString *src = [buf substringWithRange:srcRange];

			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // find optional width and height, and the src, from the attributes
			 NSString *width = nil;
			 NSString *height = nil;
			 NSTextCheckingResult *m2 = [regexWidth firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) width = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexHeight firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) height = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];

			 [converted appendString:@"[youtube"];
			 if (width != nil) [converted appendFormat:@" width=\"%@\"", width];
			 if (height != nil) [converted appendFormat:@" height=\"%@\"", height];
			 [converted appendFormat:@"]%@[/youtube]", src];
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) youtubeBToPlain:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<object.*?www.youtube.com/v/.*?>.*?<embed(.*?www.youtube.com/v/(.*?)[\"\\?].*?)>.*?</object>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSRegularExpression *regexWidth = [NSRegularExpression
									   regularExpressionWithPattern:@"width\\s*=\\s*\"(.*?)\""
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	NSRegularExpression *regexHeight = [NSRegularExpression
										regularExpressionWithPattern:@"height\\s*=\\s*\"(.*?)\""
										options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
										error:&error];	
	
	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange attrsRange = [match rangeAtIndex:1];
			 NSRange srcRange = [match rangeAtIndex:2];
			 NSString *attrsString = [buf substringWithRange:attrsRange];
			 NSString *src = [buf substringWithRange:srcRange];
			 
			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // find optional width and height, and the src, from the attributes
			 NSString *width = nil;
			 NSString *height = nil;
			 NSTextCheckingResult *m2 = [regexWidth firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) width = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexHeight firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) height = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 
			 [converted appendString:@"[youtube"];
			 if (width != nil) [converted appendFormat:@" width=\"%@\"", width];
			 if (height != nil) [converted appendFormat:@" height=\"%@\"", height];
			 [converted appendFormat:@"]%@[/youtube]", src];
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) youtubeCToPlain:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"<embed(.*?www.youtube.com/v/(.*?)[\"\\?].*?)>.*?</embed>"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSRegularExpression *regexWidth = [NSRegularExpression
									   regularExpressionWithPattern:@"width\\s*=\\s*\"(.*?)\""
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	NSRegularExpression *regexHeight = [NSRegularExpression
										regularExpressionWithPattern:@"height\\s*=\\s*\"(.*?)\""
										options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
										error:&error];	
	
	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange attrsRange = [match rangeAtIndex:1];
			 NSRange srcRange = [match rangeAtIndex:2];
			 NSString *attrsString = [buf substringWithRange:attrsRange];
			 NSString *src = [buf substringWithRange:srcRange];
			 
			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // find optional width and height, and the src, from the attributes
			 NSString *width = nil;
			 NSString *height = nil;
			 NSTextCheckingResult *m2 = [regexWidth firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) width = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexHeight firstMatchInString:attrsString options:0 range:NSMakeRange(0, [attrsString length])];
			 if (m2 != nil) height = [[attrsString substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 
			 [converted appendString:@"[youtube"];
			 if (width != nil) [converted appendFormat:@" width=\"%@\"", width];
			 if (height != nil) [converted appendFormat:@" height=\"%@\"", height];
			 [converted appendFormat:@"]%@[/youtube]", src];
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) youtubeToHtml:(NSMutableString *)buf
{
	__block NSUInteger count = 0;
	__block NSMutableString * converted = [[NSMutableString alloc] init];
	__block NSRange lastMatch = NSMakeRange(0, 0);
	
	// match <img> tags, collect the text within the tag
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"\\[youtube(.*?)\\](.*?)\\[/youtube\\]"
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSRegularExpression *regexWidth = [NSRegularExpression
									   regularExpressionWithPattern:@"width\\s*=\\s*&quot;(.*?)&quot;"
									   options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
									   error:&error];
	
	NSRegularExpression *regexHeight = [NSRegularExpression
										regularExpressionWithPattern:@"height\\s*=\\s*&quot;(.*?)&quot;"
										options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
										error:&error];

	[regex enumerateMatchesInString:buf options:NSMatchingReportCompletion range:NSMakeRange(0, [buf length])
						 usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
	 {
		 // if this is the end...
		 if (match == nil)
		 {
			 // pull over, unchanged, the range between the last match and end of buf
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, [buf length] - start)];
			 [converted appendString:unchanged];
		 }
		 
		 // we have a match
		 else
		 {
			 count++;
			 
			 NSRange matchRange = [match range];
			 NSRange attrsRange = [match rangeAtIndex:1];
			 NSString *attrsStr = [buf substringWithRange:attrsRange];
			 NSRange srcRange = [match rangeAtIndex:2];
			 NSString *srcStr = [buf substringWithRange:srcRange];
			 
			 // pull over, unchanged, the range between the last match and this one (or from the start, if we have no last match)
			 NSUInteger start = 0;
			 if (lastMatch.length > 0)
			 {
				 start = lastMatch.location+lastMatch.length;
			 }
			 NSString * unchanged = [buf substringWithRange:NSMakeRange(start, matchRange.location - start)];
			 [converted appendString:unchanged];
			 
			 // remember this as the last match
			 lastMatch = matchRange;
			 
			 // find optional width and height, alt and title from the matching string
			 NSString *width = nil;
			 NSString *height = nil;
			 NSTextCheckingResult *m2 = [regexWidth firstMatchInString:attrsStr options:0 range:NSMakeRange(0, [attrsStr length])];
			 if (m2 != nil) width = [[attrsStr substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 m2= [regexHeight firstMatchInString:attrsStr options:0 range:NSMakeRange(0, [attrsStr length])];
			 if (m2 != nil) height = [[attrsStr substringWithRange:[m2 rangeAtIndex:1]] trimToNil];
			 
			 [converted appendString:@"<iframe"];
			 if (width != nil) [converted appendFormat:@" width=\"%@\"", width];
			 if (height != nil) [converted appendFormat:@" height=\"%@\"", height];
			 [converted appendFormat:@" src=\"http://www.youtube.com/embed/%@\" frameborder=\"0\"></iframe>", srcStr];
		 }
	 }];
	
	// replace buf with the converted string
	[buf setString:converted];
	[converted release];
	
	return (count > 0);
}

- (BOOL) youtubeToPlain:(NSMutableString *)buf
{
	BOOL rv = [self youtubeAToPlain:buf];
	rv = rv | [self youtubeBToPlain:buf];
	rv = rv | [self youtubeBToPlain:buf];

	return rv;
}

#pragma mark - Public Methods

// return the string with BBCode syntax converted into html as needed.
- (NSString *) stringHtmlFromBbCode
{
	NSMutableString * buf = [[NSMutableString alloc] initWithString:self];

	// images
	[self imageToHtml:buf];
	
	// emoticons
	[self emotToHtml:buf];

	// links
	[self linkToHtml:buf];
	
	// bold
	[self boldToHtml:buf];
	
	// italic
	[self italicToHtml:buf];
	
	// underline
	[self underlineToHtml:buf];
	
	// strike
	[self strikeToHtml:buf];
	
	// font
	[self fontToHtml:buf];
	
	// center
	[self centerToHtml:buf];
	
	// youtube
	[self youtubeToHtml:buf];

	return [buf autorelease];
}

// return the string with plain text characters and BBCode syntax converted into html as needed.
- (NSString *) stringHtmlFromPlain
{
	NSMutableString * buf = [[NSMutableString alloc] initWithString:self];

	// do &amp; first, so we don't recognize "&" we just put in there as part of entities
	[buf replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [buf length])];

	// convert all entities - skip the first (&nbsp;)
	int i = 3;
	while (htmlEntities[i] != nil)
	{
		// take two of the three values
		NSString *namedEntity = htmlEntities[i++];
		// we don't need the numeric version of the entity
		i++;
		NSString *character = htmlEntities[i++];
		
		// replace the character with the named entity (e1)
		[buf replaceOccurrencesOfString:character withString:namedEntity options:0 range:NSMakeRange(0, [buf length])];
	}

	// images
	[self imageToHtml:buf];

	// emoticons
	[self emotToHtml:buf];

	// links
	[self linkToHtml:buf];

	// bold
	[self boldToHtml:buf];
	
	// italic
	[self italicToHtml:buf];
	
	// underline
	[self underlineToHtml:buf];
	
	// strike
	[self strikeToHtml:buf];
	
	// font
	[self fontToHtml:buf];
	
	// center
	[self centerToHtml:buf];
	
	// youtube
	[self youtubeToHtml:buf];

	// convert new lines to <br />
	[buf replaceOccurrencesOfString:@"\n" withString:@"<br />" options:0 range:NSMakeRange(0, [buf length])];

	// convert any multiple white space into &nbsp; (leave single spaces as spaces)

	return [buf autorelease];
}

// return the string with [quote] syntax rendered into html.
- (NSString *) stringHtmlFromQuote
{
	NSMutableString * buf = [[NSMutableString alloc] initWithString:self];
	NSUInteger total = 0;
	
	NSString *pattern = @"\\[quote\\s*=\\s*(.*?)\\](.*?)\\[/quote\\]";
	NSError *error = NULL;
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:pattern
								  options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
								  error:&error];
	
	NSUInteger pass = 0;
	NSUInteger count = 0;
	do
	{
		count = [regex replaceMatchesInString:buf
									  options:0
										range:NSMakeRange(0, [buf length])
								 withTemplate:@"<div class=\"ETquote\">$1 wrote:<div class=\"ETquoted\">$2</div></div>"];
		total += count;
		pass++;
	}
	while ((count > 0) && (pass < 100));
	
	pattern = @"\\[quote\\](.*?)\\[/quote\\]";
	regex = [NSRegularExpression
			 regularExpressionWithPattern:pattern
			 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
			 error:&error];
	
	NSUInteger pass2 = 0;
	NSUInteger count2 = 0;
	do
	{
		count2 = [regex replaceMatchesInString:buf
									  options:0
										range:NSMakeRange(0, [buf length])
								 withTemplate:@"<div class=\"ETquote\"><div class=\"ETquoted\">$1</div></div>"];
		total += count2;
		pass2++;
	}
	while ((count2 > 0) && (pass2 < 100));
	
	// add our style if needed
	if (total > 0)
	{
		[buf insertString:@"<style type=\"text/css\">.ETquote {font-weight:bold; font-family:sans-serif; font-size:small; width:80%; margin:0.5em 0px 0.5em 2em;}.ETquoted {font-weight:normal; background-color:#F3F5FF; border:1px solid #01336b; padding:0.25em 0em 0.25em 0.25em;}</style>" atIndex:0];
	}
	
	return [buf autorelease];	
}

// return the string with any html formatting "rendered" into plain (with BBCode) text.  Some formatting may be lost.
- (NSString *) stringPlainFromHtml
{
	NSMutableString * buf = [[NSMutableString alloc] initWithString:self];
	
	// remove all new lines
	[buf replaceOccurrencesOfString:@"\r\n" withString:@"" options:0 range:NSMakeRange(0, [buf length])];
	[buf replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [buf length])];
	[buf replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0, [buf length])];
	
	// remove all tabs
	[buf replaceOccurrencesOfString:@"\t" withString:@"" options:0 range:NSMakeRange(0, [buf length])];
	
	// remove all multiple white spaces
	// TODO:
	
	// convert all <br /> to new lines
	[buf replaceOccurrencesOfString:@"<br\\s*/>" withString:@"\n" options:0 range:NSMakeRange(0, [buf length])];
	
	// convert links
	[self linkToPlain:buf];
	
	// convert emoticons
	[self emotToPlain:buf];

	// convert images
	[self imageToPlain:buf];
	
	// bold
	[self boldToPlain:buf];
	
	// italic
	[self italicToPlain:buf];
	
	// underline
	[self underlineToPlain:buf];
	
	// strike
	[self strikeToPlain:buf];
	
	// font
	[self fontToPlain:buf];
	
	// center
	[self centerToPlain:buf];
	
	// youtube
	[self youtubeToPlain:buf];
	
	// convert <p> and </p> to new lines
	[self pToPlain:buf];
	
	// convert divs to new lines
	[self divToPlain:buf];
	
	// convert lists
	[self listToPlain:buf];
	[self liToPlain:buf];
	[self dtToPlain:buf];
	
	// drop all remaining tags
	[self tagsToPlain:buf];
	
	// convert html all entities
	int i = 0;
	while (htmlEntities[i] != nil)
	{
		// take the three values
		NSString *e1 = htmlEntities[i++];
		NSString *e2 = htmlEntities[i++];
		NSString *replacement = htmlEntities[i++];
		
		// replace either entity with the character
		[buf replaceOccurrencesOfString:e1 withString:replacement options:0 range:NSMakeRange(0, [buf length])];
		[buf replaceOccurrencesOfString:e2 withString:replacement options:0 range:NSMakeRange(0, [buf length])];
	}	
	
	// do &amp; last, so we don't accidently create an entity by putting in and then recognizing the "&" character
	[buf replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [buf length])];
	[buf replaceOccurrencesOfString:@"&#38;" withString:@"&" options:0 range:NSMakeRange(0, [buf length])];
	
	return [buf autorelease];
}

@end
