import React, { useState } from 'react';
import { SafeAreaView, View, Text, TextInput, Button, FlatList, ActivityIndicator, StyleSheet, Platform } from 'react-native';
import { StatusBar } from 'expo-status-bar';

export default function App() {
  const [stateName, setStateName] = useState('Andhra Pradesh');
  const [commodity, setCommodity] = useState('Tomato');
  const [loading, setLoading] = useState(false);
  const [prices, setPrices] = useState([]);
  const [error, setError] = useState(null);
  const [backendUrl, setBackendUrl] = useState(
    Platform.OS === 'android' ? 'http://10.0.2.2:5000' : 'http://localhost:5000'
  );

  const fetchPrices = async () => {
    setLoading(true);
    setError(null);
    try {
      const url = `${backendUrl}/api/prices/fetch?state=${encodeURIComponent(stateName)}&commodity=${encodeURIComponent(commodity)}`;
      const res = await fetch(url);
      if (!res.ok) throw new Error(`Server error ${res.status}`);
      const data = await res.json();
      setPrices(data.prices || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>CSP Prices</Text>

      <View style={styles.inputRow}>
        <TextInput style={styles.input} value={stateName} onChangeText={setStateName} placeholder="State" />
        <TextInput style={styles.input} value={commodity} onChangeText={setCommodity} placeholder="Commodity" />
      </View>

      <TextInput style={styles.backendInput} value={backendUrl} onChangeText={setBackendUrl} placeholder="Backend URL" />

      <Button title="Fetch Prices" onPress={fetchPrices} />

      {loading && <ActivityIndicator style={{ marginTop: 10 }} />}
      {error && <Text style={styles.error}>{error}</Text>}

      <FlatList
        style={{ marginTop: 12, width: '100%' }}
        data={prices}
        keyExtractor={(item, idx) => `${item.market}-${item.date}-${idx}`}
        renderItem={({ item }) => (
          <View style={styles.card}>
            <Text style={styles.cardTitle}>{item.market} — {item.district}</Text>
            <Text>{item.commodity} • {item.date}</Text>
            <Text>Min: {item.min_price ?? '—'}  Max: {item.max_price ?? '—'}  Modal: {item.modal_price ?? '—'}</Text>
          </View>
        )}
        ListEmptyComponent={() => !loading && <Text style={{ marginTop: 10 }}>No prices yet. Press "Fetch Prices".</Text>}
      />

      <StatusBar style="auto" />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', padding: 16 },
  title: { fontSize: 22, fontWeight: '600', marginBottom: 12 },
  inputRow: { flexDirection: 'row', width: '100%', justifyContent: 'space-between', marginBottom: 8 },
  input: { flex: 1, borderWidth: 1, borderColor: '#ccc', padding: 8, marginRight: 8, borderRadius: 6 },
  backendInput: { width: '100%', borderWidth: 1, borderColor: '#ccc', padding: 8, marginBottom: 8, borderRadius: 6 },
  card: { padding: 10, borderWidth: 1, borderColor: '#eee', borderRadius: 8, marginBottom: 8, backgroundColor: '#fafafa' },
  cardTitle: { fontWeight: '600' },
  error: { color: 'red', marginTop: 8 }
});
