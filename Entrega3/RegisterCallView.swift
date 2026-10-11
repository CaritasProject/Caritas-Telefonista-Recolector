//
//  RegisterCallView.swift
//  Entrega3
//
//  Created by Lorenzo Orrante Roman on 05/10/26.
//

import SwiftUI

struct CallRequest: Codable {
    let resultado: String
    let comentarios: String?
    let compromiso: CommitmentRequest?
}

struct CommitmentRequest: Codable {
    let importe: Double
    let id_forma_pago: Int
    let pago_unico: Bool
    let id_frecuencia: Int?
    let id_tipo_frecuencia: Int?
}

struct RegisterCallView: View {
    private let donorID = 1
    private let service = CallService()
    
    @State private var selectedResult: CallResult = .promise
    @State private var amount: String = ""
    @State private var selectedPaymentMethodID: Int?
    @State private var selectedFrequencyID: Int?
    @State private var selectedFrequencyTypeID: Int?
    @State private var comments: String = ""
    @State private var donor: Donor?
    @State private var formOptions: FormOptions?
    @State private var isLoading = false
    @State private var isSubmitting = false
    @State private var message: UserMessage?
    
    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    donorInformation
                    resultSection
                    commitmentSection
                    frequencySection
                    commentsSection
                    continueButton
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(red: 0.96, green: 0.96, blue: 0.98))
        }
        .task {
            await loadInitialData()
        }
        .alert(item: $message) { message in
            Alert(
                title: Text(message.title),
                message: Text(message.body),
                dismissButton: .default(Text("Aceptar"))
            )
        }
    }
    
    private var header: some View {
        HStack {
            Button {
                // Go back
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Atrás")
                }
            }
            
            Spacer()
            
            Text("Registrar llamada")
                .font(.headline)
            
            Spacer()
            
            Circle()
                .fill(
                        Color(
                            red: 0.00,
                            green: 0.65,
                            blue: 0.72
                        )
                    )
                .frame(width: 40, height: 40)
                .overlay {
                    Text("LR")
                        .foregroundStyle(.white)
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private var donorInformation: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(donor?.nombre ?? "Cargando donante...")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Donante #\(donorID)")
                .foregroundStyle(.secondary)

            Text("Confirmar cobro")
                .foregroundStyle(Color.cyan)
                .fontWeight(.medium)
        }
    }
    
    enum CallResult: String, CaseIterable, Identifiable {
        case promise
        case noAnswer
        case rejected

        var id: Self { self }

        var displayName: String {
            switch self {
            case .promise:
                return "Promesa"
            case .noAnswer:
                return "No contestó"
            case .rejected:
                return "Rechazó"
            }
        }

        var apiValue: String {
            switch self {
            case .promise:
                return "PROMESA"
            case .noAnswer:
                return "NO_CONTESTO"
            case .rejected:
                return "RECHAZO"
            }
        }
    }
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resultado")
                .font(.headline)

            Picker("Resultado", selection: $selectedResult) {
                ForEach(CallResult.allCases) { result in
                    Text(result.displayName)
                        .tag(result)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var commitmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compromiso")
                .font(.headline)

            VStack(spacing: 16) {
                HStack {
                    Text("Monto")
                        .foregroundStyle(.secondary)

                    Spacer()

                    TextField("$0", text: $amount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }

                Divider()

                HStack {
                    Text("Método de pago")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Picker("Método de pago", selection: $selectedPaymentMethodID) {
                        ForEach(formOptions?.paymentMethods ?? []) { method in
                            Text(method.nombre)
                                .tag(Optional(method.id))
                        }
                    }
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Frecuencia")
                .font(.headline)

            Picker("Frecuencia", selection: $selectedFrequencyID) {
                ForEach(formOptions?.frequencies ?? []) { option in
                    Text(option.nombre)
                        .tag(Optional(option.id))
                }
            }
            .pickerStyle(.segmented)

            if !isSinglePayment {
                HStack {
                    Text("Tipo de frecuencia")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Picker("Tipo de frecuencia", selection: $selectedFrequencyTypeID) {
                        ForEach(formOptions?.frequencyTypes ?? []) { type in
                            Text(type.nombre)
                                .tag(Optional(type.id))
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Comentarios")
                .font(.headline)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    }

                if comments.isEmpty {
                    Text("Agregar comentario...")
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $comments)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .background(Color.clear)
            }
            .frame(minHeight: 110)
        }
    }
    
    private var continueButton: some View {
        Button {
            Task {
                await submitCall()
            }
        } label: {
            if isSubmitting {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Text("Continuar para agendar visita")
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Color(
                        red: 0.00,
                        green: 0.65,
                        blue: 0.72
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .disabled(isLoading || isSubmitting || formOptions == nil)
    }
    
    private var isSinglePayment: Bool {
        guard let selectedFrequencyID else { return false }
        return formOptions?.frequencies.first {
            $0.id == selectedFrequencyID
        }?.isSinglePayment ?? false
    }

    private func buildRequest() throws -> CallRequest {
        if selectedResult == .promise {
            guard let paymentMethodID = selectedPaymentMethodID,
                  let frequencyID = selectedFrequencyID else {
                throw FormValidationError.missingOptions
            }

            guard let parsedAmount = Double(amount), parsedAmount > 0 else {
                throw FormValidationError.invalidAmount
            }

            if !isSinglePayment && selectedFrequencyTypeID == nil {
                throw FormValidationError.missingOptions
            }

            let commitment = CommitmentRequest(
                importe: parsedAmount,
                id_forma_pago: paymentMethodID,
                pago_unico: isSinglePayment,
                id_frecuencia: isSinglePayment ? nil : frequencyID,
                id_tipo_frecuencia: isSinglePayment ? nil : selectedFrequencyTypeID
            )

            return CallRequest(
                resultado: selectedResult.apiValue,
                comentarios: comments.isEmpty ? nil : comments,
                compromiso: commitment
            )

        } else {
            return CallRequest(
                resultado: selectedResult.apiValue,
                comentarios: comments.isEmpty ? nil : comments,
                compromiso: nil
            )
        }
    }

    @MainActor
    private func loadInitialData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            async let fetchedDonor = service.fetchDonor(id: donorID)
            async let fetchedOptions = service.fetchFormOptions()
            let (donor, options) = try await (fetchedDonor, fetchedOptions)

            self.donor = donor
            formOptions = options
            selectedPaymentMethodID = options.paymentMethods.first?.id
            selectedFrequencyID = options.frequencies.first?.id
            selectedFrequencyTypeID = options.frequencyTypes.first?.id
        } catch {
            message = UserMessage(
                title: "No se pudieron cargar los datos",
                body: error.localizedDescription
            )
        }
    }

    @MainActor
    private func submitCall() async {
        guard !isSubmitting else { return }

        do {
            let request = try buildRequest()
            isSubmitting = true
            defer { isSubmitting = false }

            let response = try await service.registerCall(
                donorID: donorID,
                request: request
            )
            message = UserMessage(
                title: "Llamada registrada",
                body: "Se creó la llamada #\(response.callID)."
            )
        } catch {
            message = UserMessage(
                title: "No se pudo registrar la llamada",
                body: error.localizedDescription
            )
        }
    }
}

private struct UserMessage: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

private enum FormValidationError: LocalizedError {
    case invalidAmount
    case missingOptions

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Ingresa un monto mayor que cero."
        case .missingOptions:
            return "Selecciona todas las opciones requeridas."
        }
    }
}

#Preview {
    RegisterCallView()
}
