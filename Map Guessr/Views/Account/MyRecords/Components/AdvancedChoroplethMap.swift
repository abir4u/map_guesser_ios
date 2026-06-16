//
//  AdvancedChoroplethMap.swift
//  Map Guessr
//
//  Created by Abir Pal on 15/06/2026.
//


import SwiftUI
import MapKit

struct AdvancedChoroplethMap: UIViewRepresentable {
    let coverageSummary: [CachedCountrySummary]
    
    private var countryPerformance: [String: Int] {
        Dictionary(uniqueKeysWithValues: coverageSummary.map { ($0.country, $0.performanceSummary) })
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = true
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        
        mapView.mapType = .mutedStandard
        mapView.pointOfInterestFilter = .excludingAll
        
        let fullWorldRect = MKMapRect.world
        let mapPadding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let fittedRect = mapView.mapRectThatFits(fullWorldRect, edgePadding: mapPadding)
        
        mapView.setVisibleMapRect(fittedRect, animated: false)
                
        loadGeoJSONShapes(into: mapView)
        
        return mapView
    }


    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.parent = self
        uiView.removeOverlays(uiView.overlays)
        loadGeoJSONShapes(into: uiView)
        uiView.setNeedsDisplay()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func loadGeoJSONShapes(into mapView: MKMapView) {
        guard let url = Bundle.main.url(forResource: "custom.geo", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? MKGeoJSONDecoder().decode(data) else {
            print("Error: Could not find or read custom.geo.json in bundle.")
            return
        }
        
        for item in json {
            guard let feature = item as? MKGeoJSONFeature else { continue }
            
            var countryName = ""
            if let propertiesData = feature.properties,
               let props = try? JSONSerialization.jsonObject(with: propertiesData) as? [String: Any] {
                countryName = props["name_en"] as? String ?? ""
            }
            
            guard !countryName.isEmpty else { continue }
            
            for geometry in feature.geometry {
                if let multiPolygon = geometry as? MKMultiPolygon {
                    multiPolygon.title = countryName
                    mapView.addOverlay(multiPolygon)
                } else if let polygon = geometry as? MKPolygon {
                    let multiPolygonWrapper = MKMultiPolygon([polygon])
                    multiPolygonWrapper.title = countryName
                    mapView.addOverlay(multiPolygonWrapper)
                }
            }
        }
    }


    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: AdvancedChoroplethMap

        init(_ parent: AdvancedChoroplethMap) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let multiPolygon = overlay as? MKMultiPolygon {
                let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
                
                let countryName = multiPolygon.title ?? ""

                let rating = parent.countryPerformance[countryName] ?? 0
                
                let fillColor: UIColor = {
                    switch rating {
                    case 3:  return .systemGreen
                    case 2:  return .systemIndigo
                    case 1:  return .systemYellow
                    default: return UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0) // Off-white
                    }
                }()
                                
                renderer.fillColor = fillColor
                renderer.strokeColor = UIColor.white.withAlphaComponent(0.5)
                renderer.lineWidth = 0.5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
