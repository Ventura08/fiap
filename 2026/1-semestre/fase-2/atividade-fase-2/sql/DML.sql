-- ============================================================
-- Vinheria Agnello — DML Script
-- Idempotente: só insere se a tabela wines estiver vazia
-- ============================================================

IF EXISTS (SELECT 1 FROM wines) GOTO done;

-- Vinhos do catálogo (image_url será preenchida após configurar o Azure Blob Storage)
INSERT INTO wines (name, grape, country, region, type, vintage, price, alcohol_content, description, is_featured)
VALUES
('Barolo Riserva',          'Nebbiolo',     'Itália',    'Piemonte',       'Tinto',     2019, 290.00, 14.0,
 'Cor rubi intensa com reflexos granada. Aroma de cereja preta, alcaçuz, rosas secas e especiarias. Taninos firmes e final longo e mineral.',
 1),

('Chardonnay Premium',      'Chardonnay',   'Chile',     'Valle Central',  'Branco',    2022, 145.00, 13.5,
 'Chardonnay fresco e elegante com notas de baunilha, manteiga e frutas tropicais. Excelente para frutos do mar.',
 0),

('Malbec Reserva',          'Malbec',       'Argentina', 'Mendoza',        'Tinto',     2021, 180.00, 14.0,
 'Tinto argentino com taninos suaves, notas de ameixa, chocolate e especiarias. Persistência longa e elegante.',
 1),

('Prosecco DOC',            'Glera',        'Itália',    'Vêneto',         'Espumante', 2023, 130.00, 11.5,
 'Espumante italiano leve, borbulhante e refrescante. Aromas de pêssego, pera e flor de laranjeira. Perfeito para brinde.',
 0),

('Cabernet Sauvignon',      'Cabernet',     'Chile',     'Maipo',          'Tinto',     2020, 220.00, 14.5,
 'Cabernet chileno estruturado com notas intensas de cassis, cedro e pimenta preta. Ótimo para carnes grelhadas.',
 0),

('Rosé de Provence',        'Grenache',     'França',    'Provence',       'Rosé',      2023, 160.00, 13.0,
 'Rosé provençal delicado, aromático e seco. Notas de morango, framboesa e flores. Versátil à mesa.',
 1),

('Vinho Verde',             'Loureiro',     'Portugal',  'Minho',          'Branco',    2023,  90.00, 11.0,
 'Vinho verde português leve, levemente frisante e refrescante. Acidez viva e mineralidade. Ideal para peixes.',
 0),

('Pinot Noir Serra Gaúcha', 'Pinot Noir',   'Brasil',    'Serra Gaúcha',   'Tinto',     2022, 195.00, 13.0,
 'Pinot Noir brasileiro com elegância, frescor e terroir único da Serra Gaúcha. Notas de cereja, framboesa e terra molhada.',
 1);

-- Label para o GOTO (fim do bloco idempotente)
done:
SELECT 'DML concluido' AS status;
