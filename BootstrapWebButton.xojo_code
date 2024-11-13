#tag Class
Protected Class BootstrapWebButton
Inherits WebButton
	#tag Event
		Sub Opening()
		  // Load FontAwesome
		  if me.NeedsFontAwesome then
		    LoadFontAwesome
		    
		  end
		  
		  // Indicate constructor has finished and rendering can be executed
		  me.mbHasFinishedConstructor = true
		  
		  // Render the raw caption
		  RenderRawCaption
		  
		  // Re-raise the Opening event
		  RaiseEvent Opening
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function Caption() As String
		  // Shadow the parent property and return the internal label
		  return me.msLabel
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Caption(assigns sValue as String)
		  // Shadow the parent property and assign to the internal label
		  msLabel = sValue
		  RenderRawCaption
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetBootstrapIcon(pName as String, iSize as Integer, cIconColor as Color) As String
		  // Check that the IconName resolves a Bootstrap Icon
		  var picIcon as WebPicture = WebPicture.BootstrapIcon(pName, cIconColor)
		  if picIcon = nil then return ""
		  
		  // WebPicture.BootstrapIcon.Data will give us a <svg> object to insert
		  var sSVG as String = WebPicture.BootstrapIcon(pName, cIconColor).Data
		  
		  // Search the SVG for the size information and replace it with our desired size
		  var rx as new Regex
		  rx.SearchPattern = "(width|height)=""(\d+)"""
		  
		  if iSize = 0 then
		    // Default bootstrap height
		    rx.ReplacementPattern = "\1=""1rem"""
		    
		  else
		    // Custom height
		    rx.ReplacementPattern = "\1=""" + iSize.ToString + """"
		    
		  end
		  
		  rx.Options.ReplaceAllMatches = true
		  
		  var sSized as String = rx.Replace(sSVG)
		  return sSized
		End Function
	#tag EndMethod

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
		  return (me.msLabel <> "")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HasIcon() As Boolean
		  return (me.IconType <> eIconTypes.None) and (me.IconName.Trim <> "")
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
		  // Wait until the constructor is finished before rendering
		  // Otherwise each property set in the IDE will trigger rendering
		  if not me.mbHasFinishedConstructor then return
		  
		  // Render the <raw> caption
		  var tarsRaw() as string
		  
		  // Add Icon
		  if me.HasIcon then
		    // Inspired by work from Brock Nash<3
		    var tarsStyle() as String
		    
		    select case me.IconType
		    case eIconTypes.Bootstrap
		      // Color options
		      var cRequest as Color = me.CaptionColor
		      if me.HasIconColor then
		        cRequest = me.IconColor
		        
		      end
		      
		      var sIcon as String = GetBootstrapIcon(me.IconName, me.IconSize, cRequest)
		      tarsRaw.AddRow("<span style=""vertical-align:0.8pt"">" + sIcon + "</span>")
		      
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
		    
		  end
		  
		  // ICON + CAPTION
		  if me.HasCaption and me.HasIcon then
		    if me.IsVertical then
		      // Add a line break for vertical alignment
		      tarsRaw.AddRow("<br>")
		      
		    else
		      // Add a non-breaking horizontal space between the icon and the text
		      tarsRaw.AddRow("&nbsp;")
		      
		    end
		    
		  end
		  
		  // CAPTION
		  if me.HasCaption then
		    var tarsStyle() as String
		    
		    if me.CaptionSize > 0 then
		      tarsStyle.AddRow("font-size: " + me.CaptionSize.ToString + "px;")
		      
		    end
		    
		    if me.HasCaptionColor then
		      tarsStyle.AddRow("color: " + rgba(me.CaptionColor))
		      
		    end
		    
		    // Build final caption
		    var tsStyle as String = String.FromArray(tarsStyle, "")
		    tarsRaw.AddRow("<span style=""" + tsStyle + """>" + me.msLabel + "</span>")
		    
		  end
		  
		  // Final <raw> statement
		  WebButton(self).Caption = "<raw>" + String.FromArray(tarsRaw, "") + "</raw>"
		  
		  
		  // Button horizontal alignment
		  select case me.HorizontalAlign
		  case TextAlignments.Left
		    me.Style.Value("display") = "inline"
		    me.Style.Value("text-align") = "left"
		    
		  case TextAlignments.Right
		    me.Style.Value("display") = "inline"
		    me.Style.Value("text-align") = "right"
		    
		  else
		    me.Style.Value("display") = ""
		    me.Style.Value("text-align") = ""
		    
		  end select
		  
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
		# BootstrapWebButton
		Xojo WebButton subclass that allows icons. This class modifies the caption
		of the button using the ``<raw></raw>`` tags to insert html that will display
		an icon in the button. The class supports both built in Bootstrap icons and
		FontAwesome 5 icons.
		
		## Usage
		To display an icon on a `BootstrapWebButton` instance select the Icon Type and
		Icon Name. Bootstrap icons will pass the icon name to Xojo's `WebPicture.BoostrapIcon`
		function. FontAwesome icons will automatically prefix, enter only the icon name
		as it is displayed in the icon list (without `fas fa-`).
		
		### Default Sizes
		By default, the BootstrapWebButton will use the global font size. This can be
		overriden with the `LabelSize` and `IconSize` properties. To use the default
		sizes, set `LabelSize` and/or `IconSize` to `0`.
		
		### Colors
		The button will use default global coloring for the label and icon. This can be
		overriden by selecting a color and setting the `HasLabelColor` or `HasIconColor`
		property `true`.
		
		### Font Awesome Pro Icons
		The class has been tested with the free versions of FontAwesome icons, though pro
		icons are expected to work. To load pro icons the FontAwesome CSS link will need
		to be changed in the Javascript loading source. This is stored in the 
		kFontAwesomeLoadJS` constant.
		
		## Authors
		Original class: Bruno Frechette - bruno@newmood.com
		
		Automagic CSS: Tim Parnell - strawberrysw.com
		
		Inspired by posts from Brock Nash
		
		## License
		This class can be modified at will, is reusable, distributable, for commercial
		or any other use.
		
		This class is distributed as "beerware". If you find this class useful and want
		to express your gratitude, buy us a beer at the next Xojo conference or send a 
		few dollars to one of the developers. If you do, we'll send you a picture
		of the beer we drank with your donation.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
		INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
		PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
		LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
		OR OTHER DEALINGS IN THE SOFTWARE.
		
		###
		
	#tag EndNote


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mcCaptionColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mcCaptionColor = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		CaptionColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return miCaptionSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  miCaptionSize = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		CaptionSize As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mbHasCaptionColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mbHasCaptionColor = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		HasCaptionColor As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mbHasIconColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mbHasIconColor = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		HasIconColor As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return meHorizontalAlign
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  meHorizontalAlign = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		HorizontalAlign As TextAlignments
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mcIconColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mcIconColor = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IconColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return msIconName
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  msIconName = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IconName As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return miIconSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  miIconSize = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IconSize As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return meIconType
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  meIconType = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IconType As eIconTypes
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mbIsVertical
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mbIsVertical = value
			  RenderRawCaption
			End Set
		#tag EndSetter
		IsVertical As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mbHasCaptionColor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mbHasFinishedConstructor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mbHasIconColor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mbIsVertical As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mbLoadedFontAwesome As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mcCaptionColor As Color
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mcIconColor As Color = &C00000000
	#tag EndProperty

	#tag Property, Flags = &h21
		Private meHorizontalAlign As TextAlignments
	#tag EndProperty

	#tag Property, Flags = &h21
		Private meIconType As eIconTypes
	#tag EndProperty

	#tag Property, Flags = &h21
		Private miCaptionSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private miIconSize As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private msIconName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private msLabel As String
	#tag EndProperty


	#tag Constant, Name = kFontAwesomeLoadJS, Type = String, Dynamic = False, Default = \"var tsFontAwesomeButtonID \x3D \'BootstrapWebButtonFAID\';\n\nif (!document.getElementById(tsFontAwesomeButtonID)) {\n    var toHead  \x3D document.getElementsByTagName(\'head\')[0];\n    var toCSS  \x3D document.createElement(\'link\');\n    toCSS.id   \x3D tsFontAwesomeButtonID;\n    toCSS.rel  \x3D \'stylesheet\';\n    toCSS.type \x3D \'text/css\';\n    toCSS.href \x3D \'//use.fontawesome.com/releases/v5.15.1/css/all.css\';\n    toCSS.media \x3D \'all\';\n    \n    toHead.appendChild(toCSS);\n    \n}", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersion, Type = Double, Dynamic = False, Default = \"1.2", Scope = Public
	#tag EndConstant


	#tag Enum, Name = eHorizontalAlignments, Flags = &h0
		Default
		  Left
		Right
	#tag EndEnum

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
			Name="Caption"
			Visible=true
			Group="Button"
			InitialValue="Untitled"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HorizontalAlign"
			Visible=true
			Group="Button"
			InitialValue=""
			Type="TextAlignments"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Left"
				"2 - Center"
				"3 - Right"
			#tag EndEnumValues
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
			Name="Default"
			Visible=true
			Group="Button"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CaptionSize"
			Visible=true
			Group="Button"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasCaptionColor"
			Visible=true
			Group="Button"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="CaptionColor"
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
			Type="String"
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
			Name="TabIndex"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
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
