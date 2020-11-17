#tag Class
Protected Class BootstrapWebButton
Inherits WebButton
	#tag Event
		Sub Opening()
		  'pass the event
		  raiseEvent opening
		  
		  #IF DebugBuild THEN
		    CheckFontawesomeLink
		  #ENDIF
		  
		  
		  
		  var rawInject() as string
		  
		  
		  
		  // ICON
		  
		  
		  if hasIcon then
		    
		    'insert icon, thanks to Brock Nash for this part
		    'the icon is wrapped in a <span style="" class="">mainData</span>
		    
		    'the style and class vary depending on the icon type
		    'styleData, classData and mainData will be populated with the relevant info, or left empty if not required.
		    
		    var iconStyleData() as string
		    var iconClassData as string
		    var iconMainData as string
		    
		    
		    select case IconType
		      
		      
		    case eIconTypes.FontAwesome5_Brands , eIconTypes.FontAwesome5_Duotone , eIconTypes.FontAwesome5_Light ,  _
		      eIconTypes.FontAwesome5_Regular , eIconTypes.FontAwesome5_Solid
		      
		      // fontawesome 5 icon
		      
		      'define the image class
		      
		      iconClassData = FontAwesomClassName + IconName
		      
		      'convert transparency from 0-255 (255=transparent) to 0-1 (0=transparent)
		      var iconAlpha as double
		      iconAlpha = (255 - IconColor.Alpha) / 255
		      
		      'set the color including alpha
		      iconStyleData.AddRow "color: rgba(" + IconColor.Red.ToString + "," + IconColor.Green.ToString + "," + IconColor.Blue.ToString + "," + iconAlpha.ToString("#.##") + ")"
		      
		      if IconSize > 0 then
		        
		        'set the icon size using the font-size statement
		        iconStyleData.AddRow "font-size: " + IconSize.ToString + "px"
		        
		        'calculate an additional margin as it's not adjusted automatically for larger sizes
		        'this is only for vertical alignment - horizontal align is made on the object width in the ide
		        var marginSize as integer
		        if IconSize > 8 then marginSize = IconSize \ 4
		        iconStyleData.AddRow "margin: " + marginSize.ToString + "px 0px " + marginSize.ToString + "px 0px"
		        
		      end if
		      
		      
		    case eIconTypes.Bootstrap
		      
		      // bootstrap built-in icon
		      
		      'set position
		      iconStyleData.AddRow "position: inherit"
		      
		      'get image using Xojo
		      iconMainData = WebPicture.BootstrapIcon(IconName,IconColor).Data
		      
		      if IconSize > 0 then
		        
		        'set the icon size using the font-size statement
		        iconStyleData.AddRow "font-size: " + IconSize.ToString + "px"
		        
		        'adjust the relative vertical position as bootstrap icons tend to be too low
		        'if the size is specified, move the icon up by 10% of its size
		        var topOffset as integer
		        topOffset = Ceiling(IconSize*0.1)
		        iconStyleData.AddRow "top: -" + topOffset.ToString + "px"
		        
		      else
		        
		        'move the icon slightly up so it looks more centered
		        iconStyleData.AddRow "top: -2px"
		        
		      end if
		      
		      
		    end select
		    
		    
		    'build style if any
		    var styleClause as string
		    if iconStyleData.Count > 0 then styleClause = " style=""" + string.FromArray(iconStyleData,"; ") + """"
		    
		    'build class data if any
		    var classClause as string
		    if iconClassData <> "" then classClause = " class=""" + iconClassData + """"
		    
		    'append the <span></span> icon data to the raw data
		    rawInject.AddRow "<span" + styleClause + classClause + ">" + iconMainData + "</span>"
		    
		    
		  end if
		  
		  
		  
		  
		  
		  // ICON + CAPTION
		  
		  'special treatment when both an icon and caption are present
		  if hasCaption and hasIcon then
		    
		    if IsVertical then
		      'if vertical, insert a paragraph to put the text below the icon
		      rawInject.AddRow "<br>"
		    else
		      'if horizontal, add a space between the icon and the text
		      rawInject.AddRow " "
		    end if
		    
		  end if
		  
		  
		  
		  
		  // CAPTION
		  
		  if hasCaption then
		    
		    var fontStyleData() as string
		    
		    
		    'define size if different than 0
		    if CaptionSize > 0 then
		      fontStyleData.AddRow "font-size: " + CaptionSize.ToString + "px"
		    end if
		    
		    
		    'define color if specified
		    if SetCaptionColor then
		      
		      'convert transparency from 0-255 (255=transparent) to 0-1 (0=transparent)
		      var captionAlpha as double
		      captionAlpha = (255 - CaptionColor.Alpha) / 255
		      
		      fontStyleData.AddRow "color: rgba(" + CaptionColor.Red.ToString + "," + CaptionColor.Green.ToString + "," + CaptionColor.Blue.ToString + "," + captionAlpha.ToString("#.##") + ")"
		      
		    end if
		    
		    
		    'wrap the caption in a <span></span> if there is any style info
		    if fontStyleData.Count > 0 then
		      rawInject.AddRow "<span style=""" + string.FromArray(fontStyleData,"; ") + """>" + me.Caption + "</span>"
		    else
		      rawInject.AddRow me.Caption
		    end if
		    
		    
		  end if
		  
		  
		  
		  
		  // FINAL RAW STATEMENT
		  
		  'replace the button caption property with the newly generated caption
		  me.caption = "<raw>" + join(rawInject,"") + "</raw>"
		  
		  
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Shared Sub CheckFontawesomeLink()
		  if isFontAwesomeLinkChecked then return
		  
		  if app.HTMLHeader.IndexOf("https://use.fontawesome.com/releases/v5.") = -1 then
		    MessageBox("Missing Font Awesome 5 Link" + endOfLine + endOfLine + _
		    "The link to Font Awesome 5 style sheet does not appear to be in app.htmlheader. In order to use Font Awesome 5, add the following (or similar): " + EndOfLine + _
		    "<link rel=""stylesheet"" href=""https://use.fontawesome.com/releases/v5.15.1/css/all.css"">" + EndOfLine + _
		    "This message only appears in debug build.")
		  end if
		  
		  isFontAwesomeLinkChecked = true
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Opening()
	#tag EndHook


	#tag Note, Name = Read Me
		By Bruno Frechette bruno@newmood.com
		Thanks to Brock Nash for the core syntax which inspired this work :-)
		
		This class modifies the caption of the button using the <raw></raw> option to add some html code to display an icon in the button.
		The class supports both bootstrap and fontawesome 5 icons.
		
		
		
		Some usage Notes...
		
		
		Font Awesome link:
		Add following parameter in app.htmlheader, which may require adjustments in the future as the version changes.
		<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.15.1/css/all.css">
		You may download the required files locally and change the link to point elsewhere.
		I may add specific information on this and even adapt the class to include the files directly in the project without any external link in the future.
		
		Font Awesome pro icons:
		Icons in Font Awesome are grouped in different themes:  solid, regular, light, duotone, brands.
		Note that light and duotone are pro icons, as well as some icons in the solid, regular and brands groups.
		Curently, the class has been tested with the free versions and the link mentioned in this doc points to the official Font Awesome CDN (content distribution network).
		It should work without problems with pro icons provided you adjust the link to the one provided with your pro subscription.
		
		Default sizes:
		Bootstrap css styles define the text size and color and icon size.
		Although the class allows to override these properties, you may want to keep the default as defined in the css.
		To use the defaults, set the icon and caption size to 0 and uncheck "SetCaptionColor" (false).
		The icon color is always used.
		
		Color transparency:
		The color picker in the Xojo IDE does not allow to select the alpha value.
		You can set the color with transparency in code.
		Put the code to set the color in the opening event of the instance.
		
		Button size:
		The width of the button as set in the IDE is kept.
		Unfortunately, the height is ignored and adjusted at runtime according to the size of the icon and text
		
		Live changes:
		The html is set for the button in its opening event and cannot be changed once set.
		
		
		
		
		Licence:
		This class can be modified at will, is reusable, distributable, for commercial or any other use.
		However you cannot blame me if it does not do what you want, creates software problems,
		physical adverse effects (pimples, rashes, itching, etc.) or causes any other bad thing.
		
		It is distributed as beerware.
		What is beerware? Well, if you find this class useful and want to express your gratitude, buy me a beer!
		Either at the next Xojo conference, or send me a few Dollars/Euros/Other through Paypal at bruno@newmood.com
		If you do, I'll send you a picture of the beer I drank with your donation.
		
		
		
		
	#tag EndNote


	#tag Property, Flags = &h0
		CaptionColor As color
	#tag EndProperty

	#tag Property, Flags = &h0
		CaptionSize As integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  'Font Awesome 5 groups the icons in different classes
			  
			  select case IconType
			    
			  case eIconTypes.FontAwesome5_Brands
			    return "fab fa-"
			    
			  case eIconTypes.FontAwesome5_Duotone
			    return "fad fa-"
			    
			  case eIconTypes.FontAwesome5_Light
			    return "fal fa-"
			    
			  case eIconTypes.FontAwesome5_Regular
			    return "far fa-"
			    
			  case eIconTypes.FontAwesome5_Solid
			    return "fas fa-"
			    
			  else
			    return ""
			    
			  end select
			End Get
		#tag EndGetter
		Private FontAwesomClassName As string
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if me.Caption = "" then
			    return false
			  else
			    return true
			  end if
			  
			End Get
		#tag EndGetter
		hasCaption As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if IconType = eIconTypes.None then
			    return false
			  else
			    return true
			  end if
			End Get
		#tag EndGetter
		hasIcon As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		IconColor As Color = &C00000000
	#tag EndProperty

	#tag Property, Flags = &h0
		IconName As string
	#tag EndProperty

	#tag Property, Flags = &h0
		IconSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		IconType As eIconTypes
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared isFontAwesomeLinkChecked As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		IsVertical As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		SetCaptionColor As Boolean
	#tag EndProperty


	#tag Enum, Name = eIconTypes, Type = Integer, Flags = &h0
		None
		  Bootstrap
		  FontAwesome5_Solid
		  FontAwesome5_Regular
		  FontAwesome5_Light
		  FontAwesome5_Duotone
		FontAwesome5_Brands
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Indicator"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="WebUIControl.Indicators"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Primary"
				"2 - Secondary"
				"3 - Success"
				"4 - Danger"
				"5 - Warning"
				"6 - Info"
				"7 - Light"
				"8 - Dark"
				"9 - Link"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Behavior"
			InitialValue="34"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Behavior"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowAutoDisable"
			Visible=true
			Group="Button"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Cancel"
			Visible=true
			Group="Button"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Caption"
			Visible=true
			Group="Button"
			InitialValue="Untitled"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Default"
			Visible=true
			Group="Button"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="hasCaption"
			Visible=false
			Group="Icon"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="hasIcon"
			Visible=false
			Group="Icon"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CaptionSize"
			Visible=true
			Group="Icon"
			InitialValue="12"
			Type="integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SetCaptionColor"
			Visible=true
			Group="Icon"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CaptionColor"
			Visible=true
			Group="Icon"
			InitialValue="&c00000000"
			Type="color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconType"
			Visible=true
			Group="Icon"
			InitialValue=""
			Type="eIconTypes"
			EditorType="Enum"
			#tag EnumValues
				"0 - None"
				"1 - Bootstrap"
				"2 - FontAwesome5_Solid"
				"3 - FontAwesome5_Regular"
				"4 - FontAwesome5_Light"
				"5 - FontAwesome5_Duotone"
				"6 - FontAwesome5_Brands"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconName"
			Visible=true
			Group="Icon"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconColor"
			Visible=true
			Group="Icon"
			InitialValue="&C00000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconSize"
			Visible=true
			Group="Icon"
			InitialValue="24"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsVertical"
			Visible=true
			Group="Icon"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockHorizontal"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockVertical"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
