Pod::Spec.new do |s|
	s.name             = 'GTToolKit'
	s.version          = '0.0.1'
	s.summary          = 'GTToolKit 工具库'
	s.homepage         = 'https://github.com/liuxc123/GTToolKit'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'liuxc123' => 'lxc_work@126.com' }
	s.source           = { :git => 'https://github.com/liuxc123/GTToolKit.git', :tag => s.version.to_s }
    s.ios.deployment_target = '8.0'
	s.requires_arc = true


    # LocationConverter
    s.subspec "LocationConverter" do |component|
        component.ios.deployment_target = '8.0'
        component.public_header_files = "components/#{component.base_name}/src/*.h"
        component.source_files = "components/#{component.base_name}/src/*.{h,m}"
    end


	# LocationManager
	s.subspec "LocationManager" do |component|
	  component.ios.deployment_target = '8.0'
	  component.public_header_files = "components/#{component.base_name}/src/*.h"
	  component.source_files = "components/#{component.base_name}/src/*.{h,m}", "components/#{component.base_name}/src/private/*.{h,m}"

      component.frameworks = "CoreLocation"
	end

    # MALocationManager
    s.subspec "MALocationManager" do |component|
        component.ios.deployment_target = '8.0'
        component.public_header_files = "components/#{component.base_name}/src/*.h"
        component.source_files = "components/#{component.base_name}/src/*.{h,m}", "components/#{component.base_name}/src/private/*.{h,m}"

        component.dependency "AMapLocation"
    end

    # MAMapManager
    s.subspec "MAMapManager" do |component|
        component.ios.deployment_target = '8.0'
        component.public_header_files = "components/#{component.base_name}/src/*.h"
        component.source_files = "components/#{component.base_name}/src/*.{h,m}", "components/#{component.base_name}/src/private/*.{h,m}"

        component.dependency "AMap3DMap"
    end

    # MANaviManager
    s.subspec "MANaviManager" do |component|
        component.ios.deployment_target = '8.0'
        component.public_header_files = "components/#{component.base_name}/src/*.h"
        component.source_files = "components/#{component.base_name}/src/*.{h,m}", "components/#{component.base_name}/src/private/*.{h,m}"

        component.frameworks = "GLKit", "Security", "SystemConfiguration", "CoreLocation", "CoreTelephony"
        component.libraries = 'c++', 'z'
        component.dependency "AMapNavi"

    end

    # MASearchManager
    s.subspec "MASearchManager" do |component|
        component.ios.deployment_target = '8.0'
        component.public_header_files = "components/#{component.base_name}/src/*.h"
        component.source_files = "components/#{component.base_name}/src/*.{h,m}", "components/#{component.base_name}/src/private/*.{h,m}"

        component.dependency "AMapSearch"
    end
    
    # Bluetooth
    s.subspec "Bluetooth" do |component|
        component.ios.deployment_target = '8.0'
        component.public_header_files = "components/#{component.base_name}/src/*.h", "components/#{component.base_name}/src/assists/*.h"
        component.source_files = "components/#{component.base_name}/src/*.{h,m}", "components/#{component.base_name}/src/private/*.{h,m}", "components/#{component.base_name}/src/assists/*.{h,m}"

        component.frameworks = 'CoreBluetooth'
    end
    
    # Permission
    s.subspec "Permissions" do |component|
        component.ios.deployment_target = '8.0'
        component.public_header_files = "components/#{component.base_name}/src/*.h"
        
        component.subspec 'All' do |all|
            all.public_header_files = "components/#{component.base_name}/src/*.h"
            all.source_files = "components/#{component.base_name}/src/*.{h,m}"
        end
        
        component.subspec 'Base' do |base|
            base.public_header_files = "components/#{component.base_name}/src/*.h"
            base.source_files = 'components/#{component.base_name}/src/GTPermissionSetting.{h,m}','components/#{component.base_name}/src/GTPermission.{h,m}'
        end
        
        component.subspec 'Camera' do |camera|
            camera.public_header_files = "components/#{component.base_name}/src/*.h"
            camera.source_files = 'components/#{component.base_name}/src/GTPermissionCamera.{h,m}'
        end
        
        component.subspec 'Photo' do |photo|
            photo.public_header_files = "components/#{component.base_name}/src/*.h"
            photo.source_files = 'components/#{component.base_name}/src/GTPermissionPhotos.{h,m}'
        end
        
        component.subspec 'Contact' do |contact|
            contact.public_header_files = "components/#{component.base_name}/src/*.h"
            contact.source_files = 'components/#{component.base_name}/src/GTPermissionContacts.{h,m}'
        end
        
        component.subspec 'Location' do |location|
            location.public_header_files = "components/#{component.base_name}/src/*.h"
            location.source_files = 'components/#{component.base_name}/src/GTPermissionLocation.{h,m}'
        end
        
        component.subspec 'Reminder' do |reminder|
            reminder.public_header_files = "components/#{component.base_name}/src/*.h"
            reminder.source_files = 'components/#{component.base_name}/src/GTPermissionReminders.{h,m}'
        end
        
        component.subspec 'Calendar' do |calendar|
            calendar.public_header_files = "components/#{component.base_name}/src/*.h"
            calendar.source_files = 'components/#{component.base_name}/src/GTPermissionCalendar.{h,m}'
        end
        
        component.subspec 'Microphone' do |microphone|
            microphone.public_header_files = "components/#{component.base_name}/src/*.h"
            microphone.source_files = 'components/#{component.base_name}/src/GTPermissionMicrophone.{h,m}'
        end
        
        component.subspec 'Health' do |health|
            health.public_header_files = "components/#{component.base_name}/src/*.h"
            health.source_files = 'components/#{component.base_name}/src/GTPermissionHealth.{h,m}'
        end
        
        component.subspec 'Net' do |net|
            net.public_header_files = "components/#{component.base_name}/src/*.h"
            net.source_files = 'components/#{component.base_name}/src/GTPermissionNet.{h,m}','components/#{component.base_name}/src/NetReachability.{h,m}','components/#{component.base_name}/src/GTPermissionData.{h,m}'
        end
        
    end



end
