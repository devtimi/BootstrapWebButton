#tag Class
Protected Class BootstrapWebButton
Inherits WebButton
	#tag Event
		Sub Opening()
		  // Load FontAwesome
		  if me.NeedsFontAwesome then
		    LoadFontAwesome
		    
		  end
		  
		  // Render the raw caption
		  RenderRawCaption
		  
		  // Re-raise the Opening event
		  RaiseEvent Opening
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function GetFontAwesomeClassPrefix() As String
		  // Font Awesome 5 groups the icons in different classes
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
		    dim ex as new PlatformNotSupportedException
		    ex.Message = "This icon type has not been implemented."
		    raise ex
		    
		  end select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasCaption() As Boolean
		  return (me.Caption <> "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasIcon() As Boolean
		  return (me.IconType <> eIconTypes.None)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LoadFontAwesome()
		  // Send the JS that loads FontAwesome to the browser
		  // Local loaded boolean protects against overloading, but
		  // the script is also designed to prevent overloading as well
		  if not mbLoadedFontAwesome then
		    me.ExecuteJavaScript(kFontAwesomeLoadJS)
		    me.mbLoadedFontAwesome = true
		    
		  end
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NeedsFontAwesome() As Boolean
		  // Return a boolean indicating whether or not this button needs to load FontAwesome
		  // Public method because it's informative
		  var tbIsFontAwesome as Boolean
		  
		  tbIsFontAwesome = tbIsFontAwesome or (me.IconType = eIconTypes.FontAwesome5_Brands)
		  tbIsFontAwesome = tbIsFontAwesome or (me.IconType = eIconTypes.FontAwesome5_Duotone)
		  tbIsFontAwesome = tbIsFontAwesome or (me.IconType = eIconTypes.FontAwesome5_Light)
		  tbIsFontAwesome = tbIsFontAwesome or (me.IconType = eIconTypes.FontAwesome5_Regular)
		  tbIsFontAwesome = tbIsFontAwesome or (me.IconType = eIconTypes.FontAwesome5_Solid)
		  
		  return tbIsFontAwesome
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RenderRawCaption()
		  // Render the <raw> caption
		  var tarsRaw() as string
		  
		  // Add Icon
		  if me.HasIcon then
		    // Inspired by work from Brock Nash<3
		    var tarsStyle() as String
		    
		    select case me.IconType
		    case eIconTypes.Bootstrap
		      // WebPicture.BootstrapIcon(IconName, IconColor).Data
		      // will give us a <svg> object to insert
		      
		      // Icon ends up very low without this
		      tarsStyle.AddRow("position: inherit")
		      
		      // Vertical offset
		      var tsOffset as String = "-2"
		      
		      if me.IconSize > 0 then
		        tarsStyle.AddRow("font-size: " + me.IconSize.ToString + "px;")
		        
		        // Calculate new vertical offset, 15% of size
		        var tiOffset as Integer = Ceiling(me.IconSize * 0.15)
		        tsOffset = "-" + tiOffset.ToString
		        
		      end
		      
		      tarsStyle.AddRow(tsOffset)
		      
		      // Color options
		      var tcRequest as Color = me.LabelColor
		      if me.HasIconColor then
		        tcRequest = me.IconColor
		        
		      end
		      
		      // Build final icon tag
		      var tsIcon as String = WebPicture.BootstrapIcon(me.IconName, tcRequest).Data
		      var tsStyle as String = String.FromArray(tarsStyle, "")
		      
		      tarsRaw.AddRow("<span style=""" + tsStyle + """>" + tsIcon + "</span>")
		      
		    case eIconTypes.FontAwesome5_Brands, eIconTypes.FontAwesome5_Duotone, _
		      eIconTypes.FontAwesome5_Light, eIconTypes.FontAwesome5_Regular, _
		      eIconTypes.FontAwesome5_Solid
		      // FontAwesome 5 icon
		      var tsClass as String = GetFontAwesomeClassPrefix + me.IconName
		      
		      if me.HasIconColor then
		        tarsStyle.AddRow("color: " + rgba(IconColor))
		        
		      end
		      
		      if me.IconSize > 0 then
		        tarsStyle.AddRow("font-size: " + me.IconSize.ToString + "px;")
		        
		        // Calculate an additional vertical margin because it's not adjusted automatically for larger sizes
		        // Only for vertical alignment - horizontal align is made on the object width in the ide
		        if me.IsVertical and  me.IconSize > 8 then
		          var tiMargin as Integer = me.IconSize \ 4
		          tarsStyle.AddRow("margin: " + tiMargin.ToString + "px 0;")
		          
		        end
		        
		      end
		      
		      // Build final icon tag
		      var tsStyle as String = String.FromArray(tarsStyle, "")
		      tarsRaw.AddRow("<span class=""" + tsClass + """ style=""" + tsStyle + """></span>")
		      
		    end select
		    
		  end if
		  
		  // ICON + CAPTION
		  if me.HasCaption and me.HasIcon then
		    if me.IsVertical then
		      // Add a line break for vertical alignment
		      tarsRaw.AddRow("<br>")
		      
		    else
		      // Add a horizontal space between the icon and the text
		      tarsRaw.AddRow(" ")
		      
		    end
		    
		  end
		  
		  // CAPTION
		  if me.HasCaption then
		    var tarsStyle() as String
		    
		    if me.LabelSize > 0 then
		      tarsStyle.AddRow("font-size: " + me.LabelSize.ToString + "px;")
		      
		    end
		    
		    if me.HasLabelColor then
		      tarsStyle.AddRow("color: " + rgba(me.LabelColor))
		      
		    end
		    
		    // Build final caption
		    var tsStyle as String = String.FromArray(tarsStyle, "")
		    tarsRaw.AddRow("<span style=""" + tsStyle + """>" + me.Label + "</span>")
		    
		  end if
		  
		  // Final <raw> statement
		  me.Caption = "<raw>" + String.FromArray(tarsRaw, "") + "</raw>"
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function rgba(tcTarget as Color) As String
		  // Convert transparency from 0-255 (255=transparent) to 0-1 (0=transparent)
		  var tdAlpha as Double = (255 - tcTarget.Alpha) / 255
		  
		  // Return CSS rgba string from Xojo color
		  var tsRGBA as String = "rgba(" + tcTarget.Red.ToString + _
		  ", " + tcTarget.Green.ToString + ", " + tcTarget.Blue.ToString + _
		  ", " + tdAlpha.ToString("#.##") + ");"
		  
		  return tsRGBA
		End Function
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


	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  return WebButton(self).Caption
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Prevent Xojo Developers from setting the caption
			  WebButton(self).Caption = value
			End Set
		#tag EndSetter
		Private Caption As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mHasIconColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasIconColor = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		HasIconColor As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mHasCaptionColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasCaptionColor = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		HasLabelColor As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIconColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIconColor = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IconColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIconName
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIconName = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IconName As string
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIconSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIconSize = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IconSize As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIconType
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIconType = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IconType As eIconTypes
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIsVertical
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIsVertical = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IsVertical As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mLabel
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mLabel = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		Label As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mCaptionColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mCaptionColor = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		LabelColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mCaptionSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mCaptionSize = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		LabelSize As integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mbLoadedFontAwesome As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaptionColor As color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaptionSize As integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasCaptionColor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasIconColor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconColor As Color = &C00000000
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconName As string
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIconType As eIconTypes
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mIsVertical As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLabel As String
	#tag EndProperty


	#tag Constant, Name = kFontAwesomeLoadJS, Type = String, Dynamic = False, Default = \"var tsFontAwesomeButtonID \x3D \'BootstrapWebButtonFAID\';\n\nif (!document.getElementById(tsFontAwesomeButtonID)) {\n    var toHead  \x3D document.getElementsByTagName(\'head\')[0];\n    var toCSS  \x3D document.createElement(\'link\');\n    toCSS.id   \x3D tsFontAwesomeButtonID;\n    toCSS.rel  \x3D \'stylesheet\';\n    toCSS.type \x3D \'text/css\';\n    toCSS.href \x3D \'//use.fontawesome.com/releases/v5.15.1/css/all.css\';\n    toCSS.media \x3D \'all\';\n    \n    toHead.appendChild(toCSS);\n    \n}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersion, Type = Double, Dynamic = False, Default = \"1.1", Scope = Public
	#tag EndConstant


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
			Visible=false
			Group="Button"
			InitialValue=""
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
			Name="Label"
			Visible=true
			Group="Button"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LabelSize"
			Visible=true
			Group="Button"
			InitialValue=""
			Type="integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasLabelColor"
			Visible=true
			Group="Button"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LabelColor"
			Visible=true
			Group="Button"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconType"
			Visible=true
			Group="Button"
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
			Group="Button"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconSize"
			Visible=true
			Group="Button"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasIconColor"
			Visible=true
			Group="Button"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IconColor"
			Visible=true
			Group="Button"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsVertical"
			Visible=true
			Group="Button"
			InitialValue=""
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
