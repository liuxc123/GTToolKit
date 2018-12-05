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


end
